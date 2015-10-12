class AddOrderChargeRefToOrders < ActiveRecord::Migration
  def up
    add_reference   :orders, :order_charge
    add_foreign_key :orders, :order_charges
  end

  def down
    remove_column :orders, :order_charge_id
  end
end
