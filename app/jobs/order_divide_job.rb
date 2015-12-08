class OrderDivideJob < ActiveJob::Base

  class OrderNotSigned < StandardError; ;end
  class OrderHadDivided < StandardError; ;end

  include Loggerable

  queue_as :orders

  LEVEL_AMOUNT_FIELDS = [:share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3]

  attr_reader :order_income

  def perform(order)
    @order = order
    if not order.reload.signed?
      logger.error "Break divide order: #{@order.number} as it is not signed!"
      raise OrderNotSigned
    end
    if order.sharing_rewared?
      logger.error "Break divide order: #{@order.number} as it had divided!"
      raise OrderHadDivided
    end

    @order_income = Rails.env.production? ? @order.paid_amount : @order.pay_amount
    logger.info "Start divide @order: #{order.number}, total_paid: #{@order_income}"

    refunded_money = @order.order_item_refunds.successed.sum(:money)
    logger.info "Divide order: #{@order.number}, reduce refund money #{refunded_money}"
    @order_income -= refunded_money

    start_divide_order_paid_amount

    logger.info "Done divide order: #{@order.number}"
  rescue => exception
    send_exception_message(exception, @order.attributes)
  end

  private

  #
  # 订单完成开始分账
  # 1. 商家营收收入
  # 2. 用户分享收入
  # 3. 平台|创客收入
  #
  def start_divide_order_paid_amount
    # NOTE
    # ----------------------
    # Any fail transaction should raise Exception
    # Never rescue the ActiveRecord::StatementInvalid OR any PGError
    # Read More in http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
    # ----------------------
    Order.transaction do
      begin
        @order.order_items.each do |order_item|
          reward_sharing_users order_item do |reward_amount|
            @order_income -= reward_amount
          end
        end

        divide_income_for_official_or_agent do |divide_amount|
          @order_income -= divide_amount
        end

        SellingIncome.create!(user: @order.seller, amount: order_income, order: @order)
        @order.update_columns(income: order_income, sharing_rewared: true)
        @order.complete!
      rescue => e
        logger.error "!!!Exception raise up! Dividing order: #{@order.number} ! Message: #{e.message} !!!"
        raise e
      end
    end
  end

  def divide_income_for_official_or_agent
    seller = @order.seller
    if seller.service_rate && order_income > 0
      divide_income = (order_income * seller.service_rate / 100).truncate(2)
      agent_divide_income = 0

      if agent = seller.agent
        agent_divide_income = (divide_income / 2).truncate(2)
        divide_record = DivideIncome.create!(
          order: @order,
          amount: agent_divide_income,
          user: agent
        )
        logger.info(
          "Divide order: #{@order.number}, [CAgent id: #{divide_record.id}, amount: #{agent_divide_income} ]")
      end

      official_divide_income = divide_income - agent_divide_income
      divide_record = DivideIncome.create!(
        order: @order,
        amount: official_divide_income,
        user: User.official_account
      )
      logger.info(
        "Divide order: #{@order.number}, [OAgent id: #{divide_record.id}, amount: #{official_divide_income} ]")

      yield divide_income

    end
  end

  def reward_sharing_users(order_item, &block)
    return false if order_item.order_item_refunds.successed.where('money > 0').exists?

    sharing_node = order_item.sharing_node
    return false if sharing_node.blank?

    product = order_item.product
    product_inventory = order_item.nestest_version_inventory

    LEVEL_AMOUNT_FIELDS.each_with_index do |key, index|
      reward_amount = get_reward_amount_by_product_level_and_order_item(product_inventory, key, order_item)
      reward_amount = reward_amount * order_item.amount
      reward_amount = parse_divide_amount(reward_amount)

      if reward_amount > 0
        sharing_income = SharingIncome.create!(
          level: index + 1,
          user_id: sharing_node.user_id,
          seller_id: product.user_id,
          order_item: order_item,
          sharing_node: sharing_node,
          amount: reward_amount
        )
        logger.info "Divide order: #{@order.number}, [Sharing id: #{sharing_income.id}, amount: #{reward_amount} ]"
        yield reward_amount
      end

      sharing_node = sharing_node.parent
      break if sharing_node.blank?
    end
  end

  def get_reward_amount_by_product_level_and_order_item(product_inventory, level, order_item)
    reward_amount = product_inventory.read_attribute(level)
    if level == :share_amount_lv_1 && (order_item.privilege_amount > product_inventory.privilege_amount)
      reward_amount -= (order_item.privilege_amount - product_inventory.privilege_amount)
    end
    reward_amount
  end

  def parse_divide_amount(amount)
    amount <= order_income ? amount : order_income
  end

end
