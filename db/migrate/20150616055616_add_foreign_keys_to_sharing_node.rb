class AddForeignKeysToSharingNode < ActiveRecord::Migration
  def change
    add_foreign_key :sharing_nodes, :users, on_delete: :cascade
    add_foreign_key :sharing_nodes, :products, on_delete: :cascade
  end
end
