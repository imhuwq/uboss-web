class CreateWithdrawRecords < ActiveRecord::Migration
  def change
    create_table :withdraw_records do |t|
      t.belongs_to :user

      t.integer :state, default: 0
      t.float :amount, default: 0
      t.string :bank_info

      t.datetime :process_at
      t.datetime :done_at

      t.timestamps null: false
    end

    add_foreign_key :withdraw_records, :users
  end
end
