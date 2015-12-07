class RemoveRefundStateToOrderItems < ActiveRecord::Migration
  def change
    remove_column :order_items, :refund_state, :integer
  end
end
