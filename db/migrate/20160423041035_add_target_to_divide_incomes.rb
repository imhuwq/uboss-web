class AddTargetToDivideIncomes < ActiveRecord::Migration
  def change
    add_column :divide_incomes, :target_type, :string
    add_column :divide_incomes, :target_id, :integer
  end
end
