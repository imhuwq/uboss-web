class CreateRefundReasons < ActiveRecord::Migration
  def change
    create_table :refund_reasons do |t|
      t.string :reason

      t.timestamps null: false
    end
  end
end
