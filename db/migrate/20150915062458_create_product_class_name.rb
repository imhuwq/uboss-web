class CreateProductClassName < ActiveRecord::Migration
  def change
    create_table :product_class_names do |t|
      t.string  :name
      t.integer :parent_id
      t.timestamps null: false
    end
  end
end
