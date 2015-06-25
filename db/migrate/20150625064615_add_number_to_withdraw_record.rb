class AddNumberToWithdrawRecord < ActiveRecord::Migration
  def change
    add_column :withdraw_records, :number, :string

    add_index :withdraw_records, :number, unique: true
  end
end
