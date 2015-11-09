class CreateProductPropertyValue < ActiveRecord::Migration
  def change
    create_table :product_property_values do |t|
      t.string  :value
      t.integer :product_property_id
      t.integer :product_class_id
      t.timestamps null: false
    end
  end
end
