class CreateSupplierProductInventories < ActiveRecord::Migration
  def change
    create_table :supplier_product_inventories do |t|
      t.decimal :cost_price
      t.decimal :suggest_price_lower
      t.decimal :suggest_price_upper
      t.integer :quantity
      t.boolean :for_sale, default: true
      t.integer :product_inventory_id

      t.timestamps null: false
    end
    add_index :supplier_product_inventories, :product_inventory_id
  end
end
