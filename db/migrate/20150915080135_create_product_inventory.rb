class CreateProductInventory < ActiveRecord::Migration
  def change
    create_table :product_inventories do |t|
      t.integer :product_id
      t.integer :product_class_id
      t.json    :sku_attributes
      t.timestamps null: false
    end
  end
end
