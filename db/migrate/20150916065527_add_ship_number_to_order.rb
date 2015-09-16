class AddShipNumberToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :ship_number, :string
  end
end
