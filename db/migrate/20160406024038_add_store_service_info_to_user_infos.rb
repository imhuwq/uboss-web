class AddStoreServiceInfoToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :table_count, :integer, default: 0
    add_column :user_infos, :table_expired_in, :integer, default: 0
  end
end
