class AddPrivilegeAmountToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :privilege_amount, :decimal, default: 0
  end
end
