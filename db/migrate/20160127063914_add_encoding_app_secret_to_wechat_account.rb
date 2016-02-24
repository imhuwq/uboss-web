class AddEncodingAppSecretToWechatAccount < ActiveRecord::Migration
  def change
    add_column :wechat_accounts, :encoding_app_secret, :string
  end
end
