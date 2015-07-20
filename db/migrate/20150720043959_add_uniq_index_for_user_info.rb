class AddUniqIndexForUserInfo < ActiveRecord::Migration
  def change
    add_index :user_infos, :user_id, unique: true
  end
end
