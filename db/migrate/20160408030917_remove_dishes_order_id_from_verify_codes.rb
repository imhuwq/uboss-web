class RemoveDishesOrderIdFromVerifyCodes < ActiveRecord::Migration
  def change
    remove_column :verify_codes, :dishes_order_id, :integer
  end
end
