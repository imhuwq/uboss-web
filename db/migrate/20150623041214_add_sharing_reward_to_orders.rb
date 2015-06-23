class AddSharingRewardToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :sharing_rewared, :boolean, default: false
  end
end
