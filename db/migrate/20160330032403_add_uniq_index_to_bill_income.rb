class AddUniqIndexToBillIncome < ActiveRecord::Migration
  def change
    add_index :bill_incomes, [:user_id, :bill_order_id], unique: true
  end
end
