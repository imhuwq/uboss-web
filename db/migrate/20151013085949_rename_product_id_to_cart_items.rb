class RenameProductIdToCartItems < ActiveRecord::Migration
  def up
    add_reference   :cart_items, :product_inventory
    add_foreign_key :cart_items, :product_inventories
    remove_column   :cart_items, :product_id
  end

  def down
    add_reference   :cart_items, :product
    add_foreign_key :cart_items, :products
    remove_column   :cart_items, :product_inventory_id
  end
end
