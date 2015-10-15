class AddSalingToProductInventory < ActiveRecord::Migration
  def change
    add_column :product_inventories, :saling, :boolean, default: true
  end
end
