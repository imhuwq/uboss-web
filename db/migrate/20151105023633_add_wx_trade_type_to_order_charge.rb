class AddWxTradeTypeToOrderCharge < ActiveRecord::Migration
  def change
    add_column :order_charges, :wx_trade_type, :string
  end
end
