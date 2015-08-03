class AddDefaultValues < ActiveRecord::Migration
  def change
    change_column :divide_incomes, :amount, :decimal, default: 0
    change_column :order_charges, :paid_amount, :decimal, default: 0
    change_column :orders, :pay_amount, :decimal, default: 0
    change_column :selling_incomes, :amount, :decimal, default: 0
    change_column :sharing_incomes, :amount, :decimal, default: 0
    change_column :transactions, :current_amount, :decimal, default: 0
    change_column :transactions, :adjust_amount, :decimal, default: 0
  end
end
