class RemoveOrderToOrderCharges < ActiveRecord::Migration
  def up
    remove_column :order_charges, :order_id
  end

  def down
    add_reference :order_charges, :order
    add_foreign_key :order_charges, :orders
  end
end
