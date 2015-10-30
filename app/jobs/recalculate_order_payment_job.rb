class RecalculateOrderPaymentJob < ActiveJob::Base

  queue_as :default

  def perform(product_inventory)
    product_inventory.order_items.
      includes(:order).
      merge(Order.unpay).
      references(:order).
      find_each do |order_item|
        order_item.reset_payment_info
        order_item.save
      end
  end

end
