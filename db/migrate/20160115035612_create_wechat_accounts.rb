class CreateWechatAccounts < ActiveRecord::Migration
  def change
    create_table :wechat_accounts do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
