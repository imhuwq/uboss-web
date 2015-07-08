class AddStoreNameToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :store_name, :string
  end
end
