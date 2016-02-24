class AddEncodingWechatIdentifyToWechatAccount < ActiveRecord::Migration
  def change
    add_column :wechat_accounts, :wechat_identify, :string
  end
end
