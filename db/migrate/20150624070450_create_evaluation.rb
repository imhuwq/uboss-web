class CreateEvaluation < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer  :buyer_id
      t.integer  :sharer_id
      t.integer  :status, default: 0
      t.integer  :order_item_id
      t.integer  :product_id 
      t.text     :content
      t.timestamps
    end
  end
end
