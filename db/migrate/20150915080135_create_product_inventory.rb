class CreateProductInventory < ActiveRecord::Migration
  def change
    create_table :product_inventories do |t|
      t.integer :product_id
      t.integer :product_class_id
      t.integer :count
      t.jsonb   :sku_attributes, null: false, defalut: '{}'
      t.timestamps null: false
    end
    add_index :product_inventories, :sku_attributes, using: :gin
  end
end
