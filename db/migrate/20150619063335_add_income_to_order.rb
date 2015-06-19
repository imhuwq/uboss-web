class AddIncomeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :income, :float, default: 0
  end
end
