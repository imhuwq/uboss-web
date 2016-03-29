class AddWeixinOpenidToBillOrder < ActiveRecord::Migration
  def change
    add_column :bill_orders, :weixin_openid, :string
  end
end
