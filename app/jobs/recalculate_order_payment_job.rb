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
    product_inventory.orders.unpay.find_each do |order|
      order.check_paid
      if order.unpay?
        order.order_charge.close_prepay
      end
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
