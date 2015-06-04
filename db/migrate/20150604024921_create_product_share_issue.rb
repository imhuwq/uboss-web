class CreateProductShareIssue < ActiveRecord::Migration
  def change
    create_table :product_share_issues do |t|
      t.integer :product_id
      t.float   :buyer_lv_1, default: 0
      t.float   :buyer_lv_2, default: 0
      t.float   :buyer_lv_3, default: 0
      t.float   :sharer_lv_1, default: 0
      t.integer :buyer_present_way, default: 0
      t.integer :sharer_present_way, default: 0
    end
  end
end
