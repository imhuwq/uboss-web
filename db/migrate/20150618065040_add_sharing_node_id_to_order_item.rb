class AddSharingNodeIdToOrderItem < ActiveRecord::Migration

  def change
    add_column :order_items, :sharing_node_id, :integer

    add_foreign_key :order_items, :sharing_nodes
  end

end
