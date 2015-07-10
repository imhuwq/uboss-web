class AddShipedAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :shiped_at, :datetime
  end
end
