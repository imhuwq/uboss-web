class AddUserHomePageIdToSharingNode < ActiveRecord::Migration
  def change
    add_column :sharing_nodes, :self_page_id, :integer
  end
end
