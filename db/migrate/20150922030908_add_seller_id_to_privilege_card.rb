class AddSellerIdToPrivilegeCard < ActiveRecord::Migration
  def change
    add_column :privilege_cards, :seller_id, :integer
  end
end
