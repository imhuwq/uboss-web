class CreateProduct < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :name
      t.string  :code
      t.float   :original_price
      t.float   :present_price
      t.integer :count
      t.text    :content
      t.boolean :buyer_pay   ,default: true
      t.float   :traffic_expense
      t.float   :buyer_lv_1,         default: 0
      t.float   :buyer_lv_2,         default: 0
      t.float   :buyer_lv_3,         default: 0
      t.float   :sharer_lv_1,        default: 0
      t.integer :buyer_present_way,  default: 0
      t.integer :sharer_present_way, default: 0
    end
  end
end
