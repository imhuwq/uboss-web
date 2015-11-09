class RecalculateOrderPaymentJob < ActiveJob::Base

  queue_as :default

  attr_reader :product_inventory

  def perform(product_inventory)
    @product_inventory = product_inventory

    close_all_order_charge_within
    recalculate_order_payment
  end

  private

  def close_all_order_charge_within
    OrderCharge.joins(orders: { order_items: :product_inventory }).merge(Order.unpay).
      where(product_inventories: { id: product_inventory.id }).uniq.
      find_in_batches(batch_size: 100) do |overdue_order_charges|
        OrderCharge.check_and_close_prepay(order_charges: overdue_order_charges)
      end
  end

  def recalculate_order_payment
    product_inventory.order_items.includes(:order).merge(Order.unpay).references(:order).
      find_each do |order_item|
        order_item.reset_payment_info
        order_item.save
      end
  end

end
