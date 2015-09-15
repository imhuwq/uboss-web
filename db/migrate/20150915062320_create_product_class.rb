class CreateProductClass < ActiveRecord::Migration
  def change
    create_table :product_classes do |t|
      t.string  :name
      t.integer :parent_id
      t.timestamps null: false
    end
  end
end
