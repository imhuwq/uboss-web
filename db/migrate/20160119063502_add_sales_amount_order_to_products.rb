class AddSalesAmountOrderToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sales_amount_order, :integer
  end
end
