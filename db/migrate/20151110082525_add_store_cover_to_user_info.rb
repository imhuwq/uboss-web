class AddStoreCoverToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :store_cover, :string
  end
end
