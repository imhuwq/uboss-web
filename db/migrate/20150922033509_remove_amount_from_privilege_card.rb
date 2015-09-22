class RemoveAmountFromPrivilegeCard < ActiveRecord::Migration
  def change
    remove_column :privilege_cards, :amount, :decimal
  end
end
