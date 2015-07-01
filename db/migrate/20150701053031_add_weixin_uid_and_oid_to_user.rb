class AddWeixinUidAndOidToUser < ActiveRecord::Migration
  def change
    add_column :users, :weixin_unionid, :string
    add_column :users, :weixin_openid, :string
  end
end
