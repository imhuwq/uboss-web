class AddDefatutValueToProductsTrafficExpense < ActiveRecord::Migration
  def change
    change_column :products, :traffic_expense, :decimal, default: 0
  end
end
