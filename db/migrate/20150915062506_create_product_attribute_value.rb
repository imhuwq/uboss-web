class CreateProductAttributeValue < ActiveRecord::Migration
  def change
    create_table :product_attribute_values do |t|
      t.string  :value
      t.integer :product_attribute_name_id
      t.integer :product_class_id
      t.timestamps null: false
    end
  end
end
