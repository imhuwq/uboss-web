class RemoveIndexFromUserInfo < ActiveRecord::Migration
  def change
    remove_index :user_infos, :user_id
  end
end
