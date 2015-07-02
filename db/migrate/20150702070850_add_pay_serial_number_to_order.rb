class AddPaySerialNumberToOrder < ActiveRecord::Migration
  def change
    add_column :order_charges, :pay_serial_number, :string
  end
end
