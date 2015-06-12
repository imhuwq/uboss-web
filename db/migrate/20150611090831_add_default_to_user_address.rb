class AddDefaultToUserAddress < ActiveRecord::Migration
  def change
    add_column :user_addresses, :default, :boolean, default: false
  end
end
