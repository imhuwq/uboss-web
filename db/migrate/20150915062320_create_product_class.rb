class CreateProductClass < ActiveRecord::Migration
  def change
    create_table :product_classes do |t|
      t.integer :parent_id
      t.string  :name
      t.timestamps null: false
    end
  end
end
