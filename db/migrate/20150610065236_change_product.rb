class ChangeProduct < ActiveRecord::Migration
  def change
    add_column :products, :has_share_lv,:integer ,:default=>3
    add_column :products, :share_amount_total,:float,:default=>0
    add_column :products, :share_amount_lv_1,:float,:default=>0
    add_column :products, :share_amount_lv_2,:float,:default=>0
    add_column :products, :share_amount_lv_3,:float,:default=>0
    add_column :products, :share_rate_lv_1,:float,:default=>0
    add_column :products, :share_rate_lv_2,:float,:default=>0
    add_column :products, :share_rate_lv_3,:float,:default=>0
    add_column :products, :share_rate_total,:float,:default=>0
    add_column :products, :calculate_way,:integer ,:default=>0
    remove_column :products, :buyer_lv_1,:float,:default=>0
    remove_column :products, :buyer_lv_2,:float,:default=>0
    remove_column :products, :buyer_lv_3,:float,:default=>0
    remove_column :products, :sharer_lv_1,:float,:default=>0
    remove_column :products, :buyer_present_way,:integer ,:default=>0
    remove_column :products, :sharer_present_way,:integer ,:default=>0
    remove_column :products, :img_avatar,:float,:default=>0
  end
end
