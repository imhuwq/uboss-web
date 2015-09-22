class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.belongs_to :user, index: true

      t.timestamps null: false
    end

    add_foreign_key :categories, :users

    create_join_table :products, :categories do |t|
      t.index :product_id
      t.index :category_id
    end

    add_foreign_key :categories_products, :products
    add_foreign_key :categories_products, :categories
  end
end
