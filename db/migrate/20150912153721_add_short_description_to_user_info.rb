class AddShortDescriptionToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :store_short_description, :string
  end
end
