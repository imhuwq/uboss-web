class AddShipPriceToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :ship_price, :string
  end
end
