class CreateProductAttributeValue < ActiveRecord::Migration
  def change
    create_table :product_attribute_values do |t|
      t.timestamps null: false
    end
  end
end
