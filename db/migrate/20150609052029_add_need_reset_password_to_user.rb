class AddNeedResetPasswordToUser < ActiveRecord::Migration
  def change
    add_column :users, :need_reset_password, :boolean, default: false
  end
end
