class RemoveSupplyInventoryInfoTable < ActiveRecord::Migration
  def up
    drop_table :supplier_product_inventory_infos
  end

  def down
    create_table :supplier_product_inventory_infos do |t|
    add_column :supplier_product_inventory_infos, :supplier_product_inventory_id, :integer, index: true
      t.decimal :cost_price
      t.decimal :suggest_price_lower
      t.decimal :suggest_price_upper
      t.integer :quantity
      t.boolean :for_sale, default: true
      t.integer :supplier_product_inventory_id, :integer, index: true

      t.timestamps null: false
    end
    add_index :supplier_product_inventories, :product_inventory_id
  end
end
