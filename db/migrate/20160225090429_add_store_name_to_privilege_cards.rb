class AddStoreNameToPrivilegeCards < ActiveRecord::Migration
  def change
    add_column :privilege_cards, :service_store_name, :string
    add_column :privilege_cards, :ordinary_store_name, :string
  end
end
