class AddOrdinaryStoreCoverToPrivilegeCards < ActiveRecord::Migration
  def change
    add_column    :privilege_cards, :ordinary_store_cover, :string
    rename_column :privilege_cards, :store_img, :service_store_cover
  end
end
