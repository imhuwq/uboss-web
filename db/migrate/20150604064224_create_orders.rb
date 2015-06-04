class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :user
      t.integer :seller_id
      t.string :number
      t.string :mobile
      t.string :address
      t.string :invoice_title
      t.integer :state, default: 0
      t.integer :payment
      t.datetime :pay_time
      t.float :pay_amount
      t.string :pay_message

      t.timestamps null: false
    end

    add_foreign_key :orders, :users
    add_foreign_key :orders, :users, column: :seller_id, name: :fk_order_seller_foreign_key
    add_index :orders, :number, unique: true
  end
end
