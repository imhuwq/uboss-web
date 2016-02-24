class CreateRefundMessages < ActiveRecord::Migration
  def change
    create_table :refund_messages do |t|
      t.string :message
      t.decimal :money
      t.string   :user_type
      t.integer  :user_id
      t.string :money_to
      t.string :explain

      t.timestamps null: false
    end
  end
end
