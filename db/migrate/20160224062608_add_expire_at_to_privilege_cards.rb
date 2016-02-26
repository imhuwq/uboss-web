class AddExpireAtToPrivilegeCards < ActiveRecord::Migration
  def change
    add_column :privilege_cards, :qrcode_expire_at,  :datetime, default: Time.current + 1.day
  end
end
