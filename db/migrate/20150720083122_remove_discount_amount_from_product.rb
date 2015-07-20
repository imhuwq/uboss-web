class RemoveDiscountAmountFromProduct < ActiveRecord::Migration
  def up
    remove_column :products, :discount_amount
  end

  def down
    add_column :products, :discount_amount, :decimal
  end
end
