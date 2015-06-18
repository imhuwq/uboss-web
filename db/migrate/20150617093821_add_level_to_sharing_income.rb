class AddLevelToSharingIncome < ActiveRecord::Migration
  def change
    add_column :sharing_incomes, :level, :integer, default: 1
  end
end
