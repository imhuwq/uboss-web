class OrderPayedHandlerJob < ActiveJob::Base
  queue_as :orders

  LEVEL_AMOUNT_FIELDS = [:share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3]

  class OrderNotSigned < StandardError;;end
  class OrderProcessed < StandardError;;end

  def perform(order)
    raise OrderNotSigned unless order.reload.signed?
    raise OrderProcessed if order.sharing_rewared?

    seller_income = order.pay_amount

    # NOTE
    # ----------------------
    # Any fail transaction should raise Exception
    # Never rescue the ActiveRecord::StatementInvalid OR any PGError
    # Read More in http://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html
    # ----------------------
    Order.transaction do
      begin
        order.order_items.each do |order_item|
          reward_sharing_users order_item do |reward_amount|
            seller_income -= reward_amount
          end
        end

        divide_income_for_official_or_agent order, seller_income do |divide_amount|
          seller_income -= divide_amount
        end

        SellingIncome.create!(user: order.seller, amount: seller_income, order: order)
        order.update_columns(income: seller_income, sharing_rewared: true)
        order.complete!
      rescue => e
        raise e
      end
    end
  end

  private

  def divide_income_for_official_or_agent(order, income)
    seller = order.seller
    if seller.service_rate
      divide_income = income * seller.service_rate / 100
      agent_divide_income = 0

      if agent = seller.agent
        agent_divide_income = divide_income / 2
        DivideIncome.create!(order: order, amount: agent_divide_income, user: agent)
      end
      DivideIncome.create!(order: order, amount: divide_income - agent_divide_income, user: User.official_account)

      yield divide_income

    end
  end

  def reward_sharing_users order_item, &block
    sharing_node = order_item.sharing_node
    return false if sharing_node.blank?
    product = order_item.product

    LEVEL_AMOUNT_FIELDS.each_with_index do |key, index|
      reward_amount = product.read_attribute(LEVEL_AMOUNT_FIELDS[index])
      if reward_amount > 0

        yield reward_amount

        SharingIncome.create!(
          level: index + 1,
          user_id: sharing_node.user_id,
          seller_id: product.user_id,
          order_item: order_item,
          sharing_node: sharing_node,
          amount: product.read_attribute(LEVEL_AMOUNT_FIELDS[index]) * order_item.amount
        )
      end
      sharing_node = sharing_node.parent

      break if sharing_node.blank?
    end
  end

end
