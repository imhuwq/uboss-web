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

    @bonus_basic_amount = @order.order_items.inject(0) { |total_amount, order_item|
      inventory = order_item.product_inventory
      (inventory.price - inventory.share_and_privilege_amount_total) * order_item.amount
    }
    max_discount = bonus_benefit * 1000 / @bonus_basic_amount
    max_discount = max_discount > 20 ? 20 : max_discount
    discount = BigDecimal((rand(0..max_discount) / 1000.0).to_s)

    @order.order_items.each do |order_item|
      order_item.preferentials_bonuses.create(
        discount: discount,
        preferential_source: @buyer.user_info
      )
    end
  end

  def calculate_sharing_preferential
    @order.order_items.each do |order_item|
      next if order_item.sharing_node_id.blank?
      next if order_item.privilege_card.blank?

      order_item.preferentials_privileges.create(
        preferential_source: order_item.privilege_card
      )
    end
  end

  def reset_order_payment
    order.order_items.each do |order_item|
      order_item.reset_payment_info
      order_item.changed? && order_item.save
    end
  end

end
