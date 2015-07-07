class AddDefaultDiscountToProduct < ActiveRecord::Migration
  def change
    add_column :products, :discount_amount, :float
  end
end
