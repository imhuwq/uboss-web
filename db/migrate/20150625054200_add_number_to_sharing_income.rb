class AddNumberToSharingIncome < ActiveRecord::Migration
  def change
    add_column :sharing_incomes, :number, :string

    add_index :sharing_incomes, :number, unique: true
  end
end
