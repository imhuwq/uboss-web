class AddSharingNodeIdToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :sharing_node_id, :integer
  end
end
