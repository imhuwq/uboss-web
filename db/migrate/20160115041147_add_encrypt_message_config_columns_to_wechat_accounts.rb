class AddEncryptMessageConfigColumnsToWechatAccounts < ActiveRecord::Migration
  def self.up
    change_table(:wechat_accounts) do |t|
      t.string :encoding_aes_key, limit: 43
      t.string :app_id
    end
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
