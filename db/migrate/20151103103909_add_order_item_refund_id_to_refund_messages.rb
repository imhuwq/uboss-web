class AddOrderItemRefundIdToRefundMessages < ActiveRecord::Migration
  def change
    add_reference   :refund_messages, :order_item_refund
    add_foreign_key :refund_messages, :order_item_refunds
  end
end
