class AddUserIdentifyToBillOrder < ActiveRecord::Migration
  def change
    add_column :bill_orders, :user_identify, :string
  end
end
