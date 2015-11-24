class AddRongcloudTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :rongcloud_token, :string
  end
end
