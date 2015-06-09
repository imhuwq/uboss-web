class AddUserNameToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :username, :string
  end
end
