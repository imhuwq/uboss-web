class AddOrderItemRefundIdToSalesReturn < ActiveRecord::Migration
  def change
    add_column :sales_returns, :order_item_refund_id, :integer
  end
end
