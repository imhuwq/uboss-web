class AddColumnsToProductsAndCategories < ActiveRecord::Migration
  def change
    add_column :products, :show_advertisement_at, :datetime
    add_column :categories,  :show_advertisement, :boolean,  default: true
    add_column :categories,  :show_advertisement_at,  :datetime
  end
end
