class CreateSellingIncomes < ActiveRecord::Migration
  def change
    create_table :selling_incomes do |t|

      t.timestamps null: false
    end
  end
end
