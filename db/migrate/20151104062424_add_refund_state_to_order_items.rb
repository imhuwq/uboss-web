class AddRefundStateToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :refund_state, :integer, default: 0
  end
end
