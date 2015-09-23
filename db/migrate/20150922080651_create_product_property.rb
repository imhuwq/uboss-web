class CreateProductProperty < ActiveRecord::Migration
  def change
    create_table :product_properties do |t|
      t.string  :name
      t.boolean :is_key_attr, default: true
      t.integer :product_class_id
      t.timestamps null: false
    end
  end
end
