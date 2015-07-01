class AddUserInformationsToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :sex, :integer
    add_column :user_infos, :city, :string
    add_column :user_infos, :province, :string
    add_column :user_infos, :country, :string
  end
end
