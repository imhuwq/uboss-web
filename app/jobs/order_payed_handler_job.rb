class OrderPayedHandlerJob < ActiveJob::Base
  queue_as :orders

  LEVEL_AMOUNT_FIELDS = [:share_amount_lv_1, :share_amount_lv_2, :share_amount_lv_3]

  def perform(order)
    @seller_income = order.pay_amount

    Order.transaction do
      order.order_items.each do |order_item|
        reward_sharing_users order_item do |reward_amount|
          @seller_income -= reward_amount
        end
      end

      order.update_columns(income: @seller_income, sharing_rewared: true)
    end
  end

  private

  def reward_sharing_users order_item, &block
    sharing_node = order_item.sharing_node
    return false if sharing_node.blank?
    product = order_item.product

    LEVEL_AMOUNT_FIELDS.each_with_index do |key, index|
      reward_amount = product.read_attribute(LEVEL_AMOUNT_FIELDS[index])
      if reward_amount > 0

        yield reward_amount

        SharingIncome.create(
          level: index + 1,
          user_id: sharing_node.user,
          seller_id: product.user_id,
          order_item: order_item,
          sharing_node: sharing_node,
          amount: product.read_attribute(LEVEL_AMOUNT_FIELDS[index])
        )
      end
      sharing_node = sharing_node.parent

      break if sharing_node.blank?
    end
  end

end
