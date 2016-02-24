class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.belongs_to :user, null: false

      t.timestamps null: false
    end

    add_index(:categories, [:user_id, :name], unique: true)
    add_foreign_key :categories, :users

    create_join_table :products, :categories do |t|
      t.index :product_id
      t.index :category_id
    end

    add_foreign_key :categories_products, :products
    add_foreign_key :categories_products, :categories
  end
end
