class CreateBillIncomes < ActiveRecord::Migration
  def change
    create_table :bill_incomes do |t|
      t.decimal :amount
      t.integer :user_id
      t.integer :bill_order_id

      t.timestamps null: false
    end
  end
end
