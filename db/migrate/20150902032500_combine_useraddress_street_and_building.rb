class CombineUseraddressStreetAndBuilding < ActiveRecord::Migration
  def change
    UserAddress.update_all('building = CONCAT(street,building)')
    UserAddress.update_all(street: nil)
  end
end
