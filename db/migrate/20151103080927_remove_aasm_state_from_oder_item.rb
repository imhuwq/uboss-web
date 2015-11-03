class RemoveAasmStateFromOderItem < ActiveRecord::Migration
  def change
    remove_column :order_items, :aasm_state, :string
  end
end
