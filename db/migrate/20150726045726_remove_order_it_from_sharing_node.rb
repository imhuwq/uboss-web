class RemoveOrderItFromSharingNode < ActiveRecord::Migration
  def up
    remove_column :sharing_nodes, :order_id
  end

  def down
    add_column :sharing_nodes, :order_id, :integer
  end
end
