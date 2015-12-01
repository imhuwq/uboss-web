class AddAreaAndStreetToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :area, :string
    add_column :user_infos, :street, :string
  end
end
