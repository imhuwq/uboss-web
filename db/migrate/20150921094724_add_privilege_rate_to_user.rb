class AddPrivilegeRateToUser < ActiveRecord::Migration
  def change
    add_column :users, :privilege_rate, :decimal, default: 0
  end
end
