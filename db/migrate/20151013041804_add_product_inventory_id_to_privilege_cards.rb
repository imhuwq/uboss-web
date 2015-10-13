class AddProductInventoryIdToPrivilegeCards < ActiveRecord::Migration
  def change
    add_column :privilege_cards, :product_inventory_id, :integer
  end
end
