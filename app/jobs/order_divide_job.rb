class OrderDivideJob < ActiveJob::Base

  class OrderNotSigned < StandardError; ;end
  class OrderHadDivided < StandardError; ;end
  class VerifyCodeHadDivided < StandardError; ;end

  include Loggerable

  queue_as :orders

  LEVEL_AMOUNT_FIELDS = [:share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3]

  attr_reader :order_income

  def perform(object)
    case object
    when OrdinaryOrder, AgencyOrder  then perform_order_divide(object)
    when VerifyCode     then perform_service_order_divide(object)
    when DishesOrder then perform_dishes_order_divide(object)
    end
  end

  private

  #
  # 订单完成开始分账
  # 1. 用户分享收入
  # 2. 创客收入
  # 3. 城市运营商收入
  # 4. 平台收入
  # 5. 商家营收收入
  # 6. 供货商收入(如果是分销订单)
  #
  def perform_order_divide(order)
    @order = order
    @order_items = order.order_items

    if not order.reload.signed?
      logger.error "Break divide order: #{@order.number} as it is not signed!"
      raise OrderNotSigned
    end

    if order.sharing_rewared?
      logger.error "Break divide order: #{@order.number} as it had divided!"
      raise OrderHadDivided
    end

    @order_income = Rails.env.production? ? @order.paid_amount : @order.pay_amount
    logger.info "Start divide @order: #{@order.number}, total_paid: #{@order_income}"

    refunded_money = @order.order_item_refunds.successed.sum(:money)
    logger.info "Divide order: #{@order.number}, reduce refund money #{refunded_money}"
    @order_income -= refunded_money

    start_divide_order_paid_amount

    logger.info "Done divide order: #{@order.number}"
  rescue => exception
    send_exception_message(exception, @order.attributes)
  end

  def perform_service_order_divide(verify_code)
    @order = verify_code.order
    @verify_code = verify_code
    @order_items = [verify_code.target]

    if verify_code.sharing_rewared?
      logger.error "Break divide verify code: #{@verify_code.code} as it had divided!"
      raise VerifyCodeHadDivided
    end

    order_total_paid = Rails.env.production? ? @order.paid_amount : @order.pay_amount
    @order_income = order_total_paid/@order_items.first.amount

    logger.info "Start divide @order: #{@order.number}, total_paid: #{order_total_paid}, @verify_code: #{@verify_code.code}, single_verify_code_paid: #{@order_income}"

    start_divide_order_paid_amount

    logger.info "Done divide @order: #{@order.number}, @verify code: #{@verify_code.code}"
  rescue => exception
    send_exception_message(exception,  @verify_code.attributes.merge({order: @order.attributes}))
  end

  def perform_dishes_order_divide(object)
    @order = object
    @order_items = object.order_items
    @verify_code = @order.verify_code
    @order_income = Rails.env.production? ? @order.paid_amount : @order.pay_amount
    logger.info "Start divide dishes order: #{@order.number}, total_paid: #{@order_income}"

    refunded_money = @order.order_item_refunds.successed.sum(:money)
    logger.info "Divide dishes order: #{@order.number}, reduce refund money #{refunded_money}"
    @order_income -= refunded_money

    start_divide_order_paid_amount

    logger.info "Done divide dishes order: #{@order.number}"

  rescue => exception
    send_exception_message(exception, @order.attributes)
  end

  def start_divide_order_paid_amount
    # NOTE
    # ----------------------
    # Any fail transaction should raise Exception
    # Never rescue the ActiveRecord::StatementInvalid OR any PGError
    # Read More in http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
    # ----------------------
    Order.transaction do
      begin
        @order_items.each do |order_item|
          reward_sharing_users order_item do |reward_amount|
            @order_income -= reward_amount
          end
        end

        divide_income_for_official_or_agent do |divide_amount|
          @order_income -= divide_amount
        end
        supplier_divide_price = 0
        @order_items.each do |order_item|
          divide_income_for_agency order_item do |divide_amount|
            supplier_divide_price += divide_amount
            @order_income -= divide_amount
          end
        end if @order.is_agency_order?

        SellingIncome.create!(user: @order.seller, amount: order_income, order: @order)

        case @order.type
        when 'OrdinaryOrder'
          @order.update_columns(income: order_income, sharing_rewared: true)
          @order.complete!
        when 'AgencyOrder'
          @order.purchase_order.update(income: supplier_divide_price)
          @order.update_columns(income: order_income, sharing_rewared: true)
          @order.complete!
        when 'ServiceOrder'
          @verify_code.update_columns(income: order_income, sharing_rewared: true)
          @order.update_columns(income: @order.verify_codes.where(sharing_rewared: true).sum(:income))

          if !@order.verify_codes.any? { |code| !code.sharing_rewared? }
            @order.update_columns(sharing_rewared: true)
          end
        when 'DishesOrder'
          @verify_code.update_columns(income: order_income, sharing_rewared: true)
          @order.update_columns(income: order_income)
          @order.update_columns(sharing_rewared: true)
        end
      rescue => e
        logger.error "!!!Exception raise up! Dividing order: #{@order.number} ! Message: #{e.message} !!!"
        raise e
      end
    end
  end

  def divide_income_for_official_or_agent
    seller = @order.seller

    if seller.service_rate && order_income > 0
      platform_divide_income = (order_income * seller.platform_service_rate / 1000).truncate(2)
      agent_divide_income = (order_income * seller.agent_service_rate / 1000).truncate(2)

      divide_income = platform_divide_income
      operator_divide_income = 0

      # 商家创客分成
      if agent = seller.agent
        divide_record = DivideIncome.create!(
          order: @order,
          amount: agent_divide_income,
          user: agent
        )
        divide_income += agent_divide_income
        logger.info(
          "Divide order: #{@order.number}, [CAgent id: #{divide_record.id}, amount: #{agent_divide_income} ]")
      end

      # 运营商
      operator = Operator.joins(:shops).where(shops: { user_id: @order.seller_id }).first

      if operator && operator.user
        operator_divide_income = (order_income * operator.online_rate / 100).truncate(2)
        if operator_divide_income > platform_divide_income
          operator_divide_income = platform_divide_income
        end
        divide_record = DivideIncome.create!(
          order: @order,
          amount: operator_divide_income,
          user: enterprise.user,
          target: operator
        )
        logger.info(
          "Divide order: #{@order.number}, [Operator id: #{divide_record.id}, amount: #{operator_divide_income} ]")
      end

      # UBOSS平台
      official_divide_income = platform_divide_income - operator_divide_income
      if official_divide_income > 0
        divide_record = DivideIncome.create!(
          order: @order,
          amount: official_divide_income,
          user: User.official_account
        )
        logger.info(
          "Divide order: #{@order.number}, [OAgent id: #{divide_record.id}, amount: #{official_divide_income} ]")
      else
        logger.info(
          "Divide order: #{@order.number}, [OAgent Reject id: #{divide_record.id}, amount: #{official_divide_income} ]")
      end

      yield divide_income

    end
  end

  def divide_income_for_agency(order_item)
    # return if order_item.order_item_refunds.successed.where('money > 0').exists?
    product_inventory = order_item.product_inventory
    original_product_inventory = product_inventory.parent
    divide_price = product_inventory.cost_price
    divide_price = divide_price > @order_income ? @order_income : divide_price
    divide_record = DivideIncome.create!(
            order: @order,
            amount: divide_price,
            user: original_product_inventory.product.user
          )
    logger.info(
      "Divide order: #{@order.number}, [Supplier id: #{divide_record.id}, amount: #{divide_price} ]")

    yield divide_price
  end

  def reward_sharing_users(order_item, &block)
    return false if order_item.order_type == "OrdinaryOrder" && order_item.order_item_refunds.successed.where('money > 0').exists?

    sharing_node = order_item.sharing_node
    return false if sharing_node.blank?

    product = order_item.product
    product_inventory = order_item.nestest_version_inventory

    LEVEL_AMOUNT_FIELDS.each_with_index do |key, index|
      reward_amount = get_reward_amount_by_product_level_and_order_item(product_inventory, key, order_item)
      if order_item.order_type == "OrdinaryOrder"
        reward_amount = reward_amount * order_item.amount
      end
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
    # 减去友钱卡贡献的优惠
    if level == :share_amount_lv_1
      if order_item.sharer_privilege_amount > 0 && order_item.sharer_privilege_amount <= reward_amount
        reward_amount -= order_item.sharer_privilege_amount
      # 兼容处理旧的订单优惠
      elsif order_item.privilege_amount > product_inventory.privilege_amount
        reward_amount -= (order_item.privilege_amount - product_inventory.privilege_amount)
      end
    end
    reward_amount
  end

  def parse_divide_amount(amount)
    amount <= order_income ? amount : order_income
  end

end
