class CreateProductAttributeName < ActiveRecord::Migration
  def change
    create_table :product_attribute_names do |t|
      t.string  :attribute_name
      t.integer :parent_id
      t.timestamps null: false
    end
  end
end
