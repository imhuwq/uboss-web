class CreateSubAccounts < ActiveRecord::Migration
  def change
    create_table :sub_accounts do |t|
      t.integer :user_id
      t.integer :account_id
      t.integer :state

      t.timestamps null: false
    end

    add_index :sub_accounts, [:user_id, :account_id], unique: true

    add_foreign_key "sub_accounts", "users", column: "user_id"
    add_foreign_key "sub_accounts", "users", column: "account_id"
  end
end
