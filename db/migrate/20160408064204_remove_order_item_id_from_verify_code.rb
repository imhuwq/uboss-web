class RemoveOrderItemIdFromVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :user_id, :integer
    VerifyCode.find_each do |verify_code|
      if verify_code.order_item_id.present?
        order_item = OrderItem.includes(:order).find(verify_code.order_item_id)
        verify_code.user_id = order_item.order.user_id
        verify_code.target = order_item
      elsif verify_code.activity_prize.present?
        verify_code.user_id = verify_code.activity_prize.prize_winner_id
      else
        next
      end
      verify_code.save
    end
    remove_column :verify_codes, :order_item_id, :integer
  end
end
