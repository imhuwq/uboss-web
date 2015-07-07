class AddPrivilegeAmountToProduct < ActiveRecord::Migration
  def change
    add_column :products, :privilege_amount, :float, default: 0
  end
end
