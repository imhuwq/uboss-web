class CreateProductShareIssue < ActiveRecord::Migration
  def change
    create_table :product_share_issues do |t|
      t.integer :product_id
      t.integer   :buyer_lv_1_id
      t.integer   :buyer_lv_2_id
      t.integer   :buyer_lv_3_id
      t.integer   :sharer_lv_1_id
      t.timestamps
    end
  end
end
