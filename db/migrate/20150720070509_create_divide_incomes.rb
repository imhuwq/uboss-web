class CreateDivideIncomes < ActiveRecord::Migration
  def change
    create_table :divide_incomes do |t|
      t.references :user
      t.references :order
      t.decimal :amount

      t.timestamps null: false
    end
  end
end
