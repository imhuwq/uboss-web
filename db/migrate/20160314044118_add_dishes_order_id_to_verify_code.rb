class AddDishesOrderIdToVerifyCode < ActiveRecord::Migration
  def change
    add_column :verify_codes, :dishes_order_id, :integer
  end
end
