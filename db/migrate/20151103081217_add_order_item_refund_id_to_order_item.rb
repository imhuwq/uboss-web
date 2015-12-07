class AddOrderItemRefundIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :order_item_refund_id, :integer
  end
end
