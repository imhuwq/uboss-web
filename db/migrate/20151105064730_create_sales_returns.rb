class CreateSalesReturns < ActiveRecord::Migration
  def change
    create_table :sales_returns do |t|
      t.string :logistics_company
      t.string :ship_number
      t.string :description

      t.timestamps null: false
    end
  end
end
