class AddNeedSetLoginToUser < ActiveRecord::Migration
  def change
    add_column :users, :need_set_login, :boolean, default: false
  end
end
