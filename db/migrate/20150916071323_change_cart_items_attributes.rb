class ChangeCartItemsAttributes < ActiveRecord::Migration
  def up
    add_column    :cart_items, :count, :integer, default: 0
    remove_column :cart_items, :quantity
    remove_column :cart_items, :order_id
  end

  def down
    add_column    :cart_items, :quantity, :integer
    add_column    :cart_items, :order_id, :integer
    remove_column :cart_items, :count
  end

  remove_foreign_key :cart_items, :orders
end
