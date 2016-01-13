class ServiceOrderDivideJob < ActiveJob::Base

  class VerifyCodeHadDivided < StandardError; ;end

  include Loggerable

  queue_as :orders

  LEVEL_AMOUNT_FIELDS = [:share_amount_lv_1]

  attr_reader :verify_code_income

  def perform(verify_code)
    @order = verify_code.order
    @verify_code = verify_code
    verify_code_amount = verify_code.order_item.amount

    if verify_code.sharing_rewared?
      logger.error "Break divide verify code: #{@verify_code.code} as it had divided!"
      raise VerifyCodeHadDivided
    end

    @verify_code_income = Rails.env.production? ? @order.paid_amount/verify_code_amount : @order.pay_amount/verify_code_amount
    logger.info "Start divide @verify_code: #{@verify_code.code}, total_paid: #{@verify_code_income}"

    start_divide_order_paid_amount

    logger.info "Done divide verify code: #{@verify_code.code}"
  rescue => exception
    send_exception_message(exception,  @verify_code.attributes.merge({order: @order.attributes}))
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
    VerifyCode.transaction do
      begin
        reward_sharing_users @verify_code.order_item do |reward_amount|
          @verify_code_income -= reward_amount
        end

        divide_income_for_official_or_agent do |divide_amount|
          @verify_code_income -= divide_amount
        end

        SellingIncome.create!(user: @order.seller, amount: verify_code_income, order: @order)
        @verify_code.update!(income: verify_code_income, sharing_rewared: true)

        @order.update!(income: @order.verify_codes.where(sharing_rewared: true).sum(:income))

        if !@order.verify_codes.any? { |code| !code.sharing_rewared? }
          @order.update!(sharing_rewared: true)
        end
      rescue => e
        logger.error "!!!Exception raise up! Dividing service order: #{@order.number} ! Message: #{e.message} !!!"
        raise e
      end
    end
  end

  def divide_income_for_official_or_agent
    seller = @order.seller

    if seller.service_rate && verify_code_income > 0
      divide_income = (verify_code_income * seller.service_rate / 100).truncate(2)
      agent_divide_income = 0

      if agent = seller.agent
        agent_divide_income = (divide_income / 2).truncate(2)
        divide_agent_record = DivideIncome.find_or_create_by!(
          order: @order,
          user: agent
        ) do |record|
          record.amount += agent_divide_income
        end

        logger.info(
          "Divide service order: #{@order.number}, [CAgent id: #{divide_agent_record.id}, amount: #{agent_divide_income} ]")
      end

      official_divide_income = divide_income - agent_divide_income
      divide_official_record = DivideIncome.find_or_create_by!(
        order: @order,
        user: User.official_account
      ) do |record|
        record.amount += official_divide_income
      end

      logger.info(
        "Divide service order: #{@order.number}, [OAgent id: #{divide_official_record.id}, amount: #{official_divide_income} ]")

      yield divide_income
    end
  end

  def reward_sharing_users(order_item, &block)
    sharing_node = order_item.sharing_node
    return false if sharing_node.blank?

    product = order_item.product
    product_inventory = order_item.nestest_version_inventory

    LEVEL_AMOUNT_FIELDS.each_with_index do |key, index|
      reward_amount = get_reward_amount_by_product_level_and_order_item(product_inventory, key, order_item)
      reward_amount = parse_divide_amount(reward_amount)

      if reward_amount > 0
        sharing_income = SharingIncome.find_or_create_by!(
          level: index + 1,
          user_id: sharing_node.user_id,
          seller_id: product.user_id,
          order_item: order_item,
          sharing_node: sharing_node
        ) do |income|
          income.amount += reward_amount
        end

        logger.info "Divide service order: #{@order.number}, [Sharing id: #{sharing_income.id}, amount: #{reward_amount} ]"
        yield reward_amount
      end

      sharing_node = sharing_node.parent
      break if sharing_node.blank?
    end
  end

  def get_reward_amount_by_product_level_and_order_item(product_inventory, level, order_item)
    reward_amount = product_inventory.read_attribute(level)
    sharer_privilege_amount = order_item.sharer_privilege_amount
    # 减去友情卡贡献的优惠
    if level == :share_amount_lv_1
      if sharer_privilege_amount > 0 && sharer_privilege_amount <= reward_amount
        reward_amount -= sharer_privilege_amount
      end
    end
    reward_amount
  end

  def parse_divide_amount(amount)
    amount <= verify_code_income ? amount : verify_code_income
  end

end
