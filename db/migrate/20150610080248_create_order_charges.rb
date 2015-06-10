class CreateOrderCharges < ActiveRecord::Migration
  def change
    create_table :order_charges do |t|
      t.belongs_to :order
      t.string :charge_id 
      t.string :channel

      t.timestamps null: false
    end

    add_foreign_key :order_charges, :orders
  end
end
