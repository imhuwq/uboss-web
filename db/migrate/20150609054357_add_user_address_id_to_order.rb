class AddUserAddressIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :user_address_id, :integer
    add_foreign_key :orders, :user_addresses
  end
end
