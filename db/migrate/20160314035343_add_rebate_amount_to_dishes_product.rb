class AddRebateAmountToDishesProduct < ActiveRecord::Migration
  def change
    add_column :products, :rebate_amount, :decimal
  end
end
