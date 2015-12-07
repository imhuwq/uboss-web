class AddUserIdToOrderItemRefund < ActiveRecord::Migration
  def change
    add_column :order_item_refunds, :user_id, :integer
  end
end
