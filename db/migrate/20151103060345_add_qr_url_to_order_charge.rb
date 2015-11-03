class AddQrUrlToOrderCharge < ActiveRecord::Migration
  def change
    add_column :order_charges, :wx_code_url, :string
  end
end
