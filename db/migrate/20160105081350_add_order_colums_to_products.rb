class AddOrderColumsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sales_amount_order, :integer
    add_column :products, :published_at_order, :integer
    add_column :products, :comprehensive_order, :integer
    add_column :products, :published_at, :datetime
  end
end
