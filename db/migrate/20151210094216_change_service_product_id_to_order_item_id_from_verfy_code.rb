class ChangeServiceProductIdToOrderItemIdFromVerfyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :order_item_id, :integer
    remove_column :verify_codes, :service_product_id, :integer
  end
end
