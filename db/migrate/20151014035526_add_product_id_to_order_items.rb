class AddProductIdToOrderItems < ActiveRecord::Migration
  def change
    add_reference   :order_items, :product
    add_foreign_key :order_items, :products
  end
end
