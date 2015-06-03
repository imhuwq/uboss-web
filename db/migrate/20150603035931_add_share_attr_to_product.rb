class AddShareAttrToProduct < ActiveRecord::Migration
  def change
    add_column :products, :buyer_lv_1, :float, default: 0
    add_column :products, :buyer_lv_2, :float, default: 0
    add_column :products, :buyer_lv_3, :float, default: 0
    add_column :products, :sharer_lv_1, :float, default: 0
    add_column :products, :buyer_present_way, :integer, default: 0
    add_column :products, :sharer_present_way, :integer, default: 0
  end
end
