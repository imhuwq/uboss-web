class CreateProduct < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :name
      t.float   :original_price
      t.float   :present_price
      t.integer :count
      t.text    :content

    end
  end
end
