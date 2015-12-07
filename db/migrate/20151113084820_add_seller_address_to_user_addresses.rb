class AddSellerAddressToUserAddresses < ActiveRecord::Migration
  def change
    add_column :user_addresses, :seller_address, :boolean, default: false
  end
end
