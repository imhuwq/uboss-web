class AddPresetnPriceToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :present_price, :float, default: 0
  end
end
