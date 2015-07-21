class AddColumnsToSellingIncome < ActiveRecord::Migration
  def change
    add_column :selling_incomes, :user_id, :integer
    add_column :selling_incomes, :order_id, :integer
    add_column :selling_incomes, :amount, :decimal

    add_foreign_key :selling_incomes, :users
    add_foreign_key :selling_incomes, :orders
  end
end
