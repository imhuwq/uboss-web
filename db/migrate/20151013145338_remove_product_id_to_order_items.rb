class RemoveProductIdToOrderItems < ActiveRecord::Migration
  def change
    remove_column :order_items, :product_id
  end
end
