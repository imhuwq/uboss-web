class ChangeColumnInProductInventroy < ActiveRecord::Migration
  def up
    change_column :product_inventories, :sku_attributes, :jsonb, default: {}
    remove_column :product_inventories, :share_rate_lv_1
    remove_column :product_inventories, :share_rate_lv_2
    remove_column :product_inventories, :share_rate_lv_3
    remove_column :product_inventories, :share_rate_total
    remove_column :product_inventories, :calculate_way
  end
  def down
    change_column :product_inventories, :sku_attributes, :jsonb, null: false
    add_column :product_inventories, :share_rate_lv_1, :integer
    add_column :product_inventories, :share_rate_lv_2, :integer
    add_column :product_inventories, :share_rate_lv_3, :integer
    add_column :product_inventories, :share_rate_total, :integer
    add_column :product_inventories, :calculate_way, :integer
  end
end
