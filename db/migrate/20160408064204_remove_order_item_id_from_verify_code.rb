class RemoveOrderItemIdFromVerifyCode < ActiveRecord::Migration
  def change
    VerifyCode.all.each do |verify_code|
      verify_code.user = verify_code.order_item.user
      verify_code.target = verify_code.order_item
      verify_code.save
    end
    remove_column :verify_codes, :order_item_id, :integer
  end
end
