class AddParentIdToProductInventories < ActiveRecord::Migration
  def change
    add_column :product_inventories, :parent_id, :integer, index: true
  end
end
