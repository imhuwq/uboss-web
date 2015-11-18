class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.references :order
      t.references :cart
      t.references :product
      #t.references :user
      t.integer    :seller_id
      t.integer    :quantity

      t.timestamps null: false
    end

    add_foreign_key :line_items, :orders
    add_foreign_key :line_items, :carts
    add_foreign_key :line_items, :products
    add_foreign_key :line_items, :users, column: :seller_id
  end
end
