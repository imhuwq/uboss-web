class AddActivityToPrivilegeCard < ActiveRecord::Migration
  def change
    add_column :privilege_cards, :activity, :boolean, default: false
  end
end
