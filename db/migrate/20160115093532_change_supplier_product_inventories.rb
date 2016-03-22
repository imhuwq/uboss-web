class ChangeSupplierProductInventories < ActiveRecord::Migration
  def change
    rename_table :supplier_product_inventories, :supplier_product_inventory_infos
    remove_column :supplier_product_inventory_infos, :product_inventory_id, :integer, index: true
    add_column :supplier_product_inventory_infos, :supplier_product_inventory_id, :integer, index: true
  end
end
