class AddUserIdToOrderCharge < ActiveRecord::Migration
  def change
    add_column :order_charges, :user_id, :integer
  end
end
