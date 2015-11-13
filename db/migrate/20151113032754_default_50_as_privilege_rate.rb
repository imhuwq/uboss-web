class Default50AsPrivilegeRate < ActiveRecord::Migration
  def up
    change_column_default :users, :privilege_rate, 50
  end
end
