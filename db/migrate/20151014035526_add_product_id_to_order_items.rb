class AddProductIdToOrderItems < ActiveRecord::Migration
  def change
    unless OrderItem.column_names.include?('product_id')
      add_reference   :order_items, :product
      add_foreign_key :order_items, :products
    end
  end
end
