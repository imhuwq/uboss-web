class AddOrderStateToOrderItemRefund < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :order_state, :integer
  end
end
