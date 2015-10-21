class AddProductInventoryIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :product_inventory_id, :integer
  end
end
