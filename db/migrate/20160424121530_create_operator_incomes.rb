class CreateOperatorIncomes < ActiveRecord::Migration
  def change
    create_table :operator_incomes do |t|
      t.integer :user_id
      t.references :resource, polymorphic: true
      t.decimal :amount, :precision => 10, :scale => 2, default: 0.0

      t.timestamps null: false
    end
  end
end
