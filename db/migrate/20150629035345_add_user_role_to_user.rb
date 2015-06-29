class AddUserRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_role_id, :integer

    add_foreign_key :users, :user_roles
  end
end
