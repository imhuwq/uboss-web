class CreateOrderItemRefunds < ActiveRecord::Migration
  def change
    create_table :order_item_refunds do |t|
      t.decimal :money
      t.integer :refund_reason_id
      t.string :description
      t.integer :order_item_id

      t.timestamps null: false
    end
  end
end
