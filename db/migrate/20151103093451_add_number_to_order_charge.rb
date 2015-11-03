class AddNumberToOrderCharge < ActiveRecord::Migration
  def change
    add_column :order_charges, :number, :string
    add_index :order_charges, :number
  end
end
