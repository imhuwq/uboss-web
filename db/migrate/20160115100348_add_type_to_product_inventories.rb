class AddTypeToProductInventories < ActiveRecord::Migration
  def change
    add_column :product_inventories, :type, :string
  end
end
