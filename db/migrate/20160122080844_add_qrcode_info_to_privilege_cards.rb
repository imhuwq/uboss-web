class AddQrcodeInfoToPrivilegeCards < ActiveRecord::Migration
  def change
    add_column :privilege_cards, :user_img,  :string
    add_column :privilege_cards, :store_img, :string
    add_column :privilege_cards, :user_name, :string
  end
end
