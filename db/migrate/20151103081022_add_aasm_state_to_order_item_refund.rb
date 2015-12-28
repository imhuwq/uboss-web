class AddAasmStateToOrderItemRefund < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :aasm_state, :string
  end
end
