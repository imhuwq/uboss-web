class AddSellerIdToSharingNode < ActiveRecord::Migration
  def change
    add_column :sharing_nodes, :seller_id, :integer
    add_index :sharing_nodes, [:user_id, :seller_id], unique: true, where: "seller_id IS NOT NULL"

    add_foreign_key :sharing_nodes, :users, column: 'seller_id'
  end
end
