class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.integer   :seller_id, index: true
      t.integer   :supplier_id, index: true
      t.integer   :state
      t.string    :number
      t.integer   :order_id
      t.decimal   :pay_amount, :precision => 10, :scale => 2
      t.datetime  :paid_at
      t.decimal   :income, precision: 10, scale: 2

      t.timestamps null: false
    end
  end
end
