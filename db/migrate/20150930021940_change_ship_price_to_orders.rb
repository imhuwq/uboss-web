class ChangeShipPriceToOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :ship_price
    add_column    :orders, :ship_price, :decimal, default: 0
  end

  def down
    remove_column :orders, :ship_price
    add_column    :orders, :ship_price, :string
  end
end
