class AddSignedAtToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :signed_at, :datetime
  end
end
