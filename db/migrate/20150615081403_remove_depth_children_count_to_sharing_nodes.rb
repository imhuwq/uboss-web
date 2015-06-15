class RemoveDepthChildrenCountToSharingNodes < ActiveRecord::Migration
  def up
    remove_column :sharing_nodes, :depth
    remove_column :sharing_nodes, :children_count
  end

  def down  
    add_column :sharing_nodes, :depth, null: false, default: 0
    add_column :sharing_nodes, :children_count, null: false, default: 0
  end
end
