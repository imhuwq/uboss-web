class AddSaleToCustomerToProductInventories < ActiveRecord::Migration
  def change
    add_column :product_inventories, :sale_to_customer, :boolean, default: true
    remove_column :product_inventories, :quantity, :integer
  end
end
