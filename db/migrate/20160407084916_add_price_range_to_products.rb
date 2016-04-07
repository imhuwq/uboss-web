class AddPriceRangeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :price_ranges, :string
  end
end
