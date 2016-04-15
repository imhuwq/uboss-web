class AddBillOrderIdToDivideIncome < ActiveRecord::Migration
  def change
    add_column :divide_incomes, :bill_order_id, :integer
  end
end
