class OrderPayedHandlerJob < ActiveJob::Base

  include Loggerable

  queue_as :orders

  LEVEL_AMOUNT_FIELDS = [:share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3]

  def perform(order)
    @order = order
    logger.info "Start divide @order: #{order.number}, total_paid: #{order.paid_amount}"
    if not order.reload.signed?
      logger.info "Break divide order: #{@order.number} as it is not signed!"
      return false
    end
    if order.sharing_rewared?
      logger.info "Break divide order: #{@order.number} as it had divided!"
      return false
    end

    start_divide_order_paid_amount
    logger.info "Done divide order: #{@order.number}"
  end

  private

  def start_divide_order_paid_amount
    seller_income = @order.paid_amount

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
            seller_income -= reward_amount
          end
        end

        divide_income_for_official_or_agent seller_income do |divide_amount|
          seller_income -= divide_amount
        end

        SellingIncome.create!(user: @order.seller, amount: seller_income, order: @order)
        @order.update_columns(income: seller_income, sharing_rewared: true)
        @order.complete!
      rescue => e
        logger.info "!!!Exception raise up! Dividing order: #{@order.number} ! Message: #{e.message} !!!"
        raise e
      end
    end
  end

  def divide_income_for_official_or_agent(income)
    seller = @order.seller
    if seller.service_rate
      divide_income = income * seller.service_rate / 100
      agent_divide_income = 0

      if agent = seller.agent
        agent_divide_income = divide_income / 2
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
    sharing_node = order_item.sharing_node
    return false if sharing_node.blank?
    product = order_item.product

    LEVEL_AMOUNT_FIELDS.each_with_index do |key, index|
      reward_amount = get_reward_amount_by_product_level_and_order_item(product, key, order_item)
      reward_amount = reward_amount * order_item.amount

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

  def get_reward_amount_by_product_level_and_order_item(product, level, order_item)
    reward_amount = product.read_attribute(level)
    if level == :share_amount_lv_1
      reward_amount -= order_item.privilege_amount
    end
    reward_amount
  end

end
