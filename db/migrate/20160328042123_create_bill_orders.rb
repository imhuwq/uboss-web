class CreateBillOrders < ActiveRecord::Migration
  def change
    create_table :bill_orders do |t|
      t.integer :user_id
      t.integer :seller_id
      t.string  :number
      t.integer :state
      t.decimal :pay_amount
      t.decimal :paid_amount
      t.integer :order_charge_id

      t.timestamps null: false
    end

    add_foreign_key :bill_orders, :users
    add_foreign_key :bill_orders, :users, column: :seller_id
    add_foreign_key :bill_orders, :order_charges
    add_index :bill_orders, :number, unique: true
  end
end
