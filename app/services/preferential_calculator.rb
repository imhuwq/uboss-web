class PreferentialCalculator

  attr_reader :order, :buyer

  def initialize(opts={})
    @order = opts[:order]
    @buyer = @order.user
  end

  def calculate_preferential_info
    calculate_bonus_preferential
    calculate_sharing_preferential
    reset_order_payment
  end

  def calculate_bonus_preferential
    bonus_benefit = buyer.bonus_benefit
    return false if bonus_benefit <= 0

    @order.order_items.each do |order_item|
      order_item.preferentials_seller_bonuses.create(
        preferential_source: @buyer.user_info
      )
    end
  end

  def calculate_sharing_preferential
    @order.order_items.each do |order_item|
      next if order_item.sharing_node_id.blank?
      next if order_item.privilege_card.blank?

      order_item.preferentials_privileges.create(
        amount: order_item.privilege_card.amount(order_item.product_inventory),
        preferential_source: order_item.privilege_card
      )
    end
  end

  def reset_order_payment
    order.transaction do
      order.order_items.each do |order_item|
        order_item.reset_payment_info
        order_item.changed? && order_item.save
      end
    end
  end

end
