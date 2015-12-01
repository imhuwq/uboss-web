class AddTypeToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :type, :string
  end
end
