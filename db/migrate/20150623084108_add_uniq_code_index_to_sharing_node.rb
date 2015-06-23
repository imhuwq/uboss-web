class AddUniqCodeIndexToSharingNode < ActiveRecord::Migration
  def change
    add_index :sharing_nodes, :code, unique: true
    add_index :sharing_nodes, [:user_id, :product_id], unique: true, where: 'parent_id IS NULL'
    add_index :sharing_nodes, [:user_id, :product_id, :parent_id], unique: true
  end
end
