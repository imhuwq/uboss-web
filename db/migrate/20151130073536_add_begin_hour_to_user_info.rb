class AddBeginHourToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :begin_hour, :string
    add_column :user_infos, :begin_minute, :string
    add_column :user_infos, :end_hour, :string
    add_column :user_infos, :end_minute, :string
  end
end
