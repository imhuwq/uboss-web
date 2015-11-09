class RenameLineItemsToCartItems < ActiveRecord::Migration
  def up
    rename_table :line_items, :cart_items
  end

  def down
    rename_table :cart_items, :line_items
  end
end
