class CleanUserAddress < ActiveRecord::Migration
  def change
    UserAddress.delete_all
  end
end
