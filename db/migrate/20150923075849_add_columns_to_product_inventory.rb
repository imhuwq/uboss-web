class AddColumnsToProductInventory < ActiveRecord::Migration
  def change
    add_column :product_inventories,:user_id,            :integer
    add_column :product_inventories,:name,               :string
    add_column :product_inventories,:price,              :decimal, default: 0.0
    add_column :product_inventories,:share_amount_total, :decimal, default: 0.0
    add_column :product_inventories,:share_amount_lv_1,  :decimal, default: 0.0
    add_column :product_inventories,:share_amount_lv_2,  :decimal, default: 0.0
    add_column :product_inventories,:share_amount_lv_3,  :decimal, default: 0.0
    add_column :product_inventories,:share_rate_lv_1,    :decimal, default: 0.0
    add_column :product_inventories,:share_rate_lv_2,    :decimal, default: 0.0
    add_column :product_inventories,:share_rate_lv_3,    :decimal, default: 0.0
    add_column :product_inventories,:share_rate_total,   :decimal, default: 0.0
    add_column :product_inventories,:calculate_way,      :integer, default: 0
    add_column :product_inventories,:privilege_amount,   :decimal, default: 0.0
  end
end
