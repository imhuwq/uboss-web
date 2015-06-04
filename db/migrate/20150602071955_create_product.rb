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
    end
  end
end
