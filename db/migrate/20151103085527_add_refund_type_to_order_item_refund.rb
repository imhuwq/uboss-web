class AddRefundTypeToOrderItemRefund < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :refund_type, :string
  end
end
