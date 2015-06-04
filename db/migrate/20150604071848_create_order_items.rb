class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.belongs_to :order
      t.belongs_to :product
      t.belongs_to :user
      t.integer :amount

      t.timestamps null: false
    end

    add_foreign_key :order_items, :orders
    add_foreign_key :order_items, :products
    add_foreign_key :order_items, :users
  end
end
