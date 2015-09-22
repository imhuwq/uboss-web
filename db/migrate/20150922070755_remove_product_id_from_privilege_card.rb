class RemoveProductIdFromPrivilegeCard < ActiveRecord::Migration
  def change
    remove_column :privilege_cards, :product_id, :integer
  end
end
