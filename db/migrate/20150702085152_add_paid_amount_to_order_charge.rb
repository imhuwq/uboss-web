class AddPaidAmountToOrderCharge < ActiveRecord::Migration
  def up
    add_column :order_charges, :paid_amount, :float
    add_column :order_charges, :payment, :integer
    add_column :order_charges, :paid_at, :datetime

    remove_column :orders, :pay_time
    remove_column :orders, :payment
  end

  def down
    remove_column :order_charges, :paid_amount
    remove_column :order_charges, :payment
    remove_column :order_charges, :paid_at

    add_column :orders, :pay_time, :datetime
    add_column :orders, :payment, :integer
  end
end
