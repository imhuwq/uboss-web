class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.float :current_amount
      t.float :adjust_amount
      t.integer :soruce_id
      t.string :source_type
      t.integer :trade_type

      t.timestamps null: false
    end

    add_foreign_key :transactions, :users
  end
end
