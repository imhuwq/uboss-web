class AddActivedToPrivilegeCard < ActiveRecord::Migration
  def change
    add_column :privilege_cards, :actived, :boolean, default: false
  end
end
