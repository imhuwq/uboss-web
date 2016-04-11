class RemoveOrderItemIdFromVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :user_id, :integer
    VerifyCode.find_each do |verify_code|
      next if verify_code.order_item_id.blank?
      order_item = OrderItem.includes(:order).find(verify_code.order_item_id)
      verify_code.user_id = order_item.order.user_id
      verify_code.target = order_item
      verify_code.save
    end
    remove_column :verify_codes, :order_item_id, :integer
  end
end
