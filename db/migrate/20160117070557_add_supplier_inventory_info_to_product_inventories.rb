class AddSupplierInventoryInfoToProductInventories < ActiveRecord::Migration
  def change
    add_column :product_inventories, :cost_price, :decimal
    add_column :product_inventories, :suggest_price_lower, :decimal
    add_column :product_inventories, :suggest_price_upper, :decimal
    add_column :product_inventories, :quantity, :integer
    add_column :product_inventories, :sale_to_agency, :boolean
  end
end
