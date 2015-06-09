class AddPayAmountToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :pay_amount, :float, default: 0
  end
end
