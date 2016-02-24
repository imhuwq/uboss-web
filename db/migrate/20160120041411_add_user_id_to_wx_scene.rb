class AddUserIdToWxScene < ActiveRecord::Migration
  def change
    add_column :wx_scenes, :user_id, :integer
  end
end
