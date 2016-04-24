class CreateUserIncomes < ActiveRecord::Migration
  def change
    create_table :user_incomes do |t|
      t.references :resource, polymorphic: true
      t.integer    :user_id
      t.decimal    :amount, :precision => 10, :scale => 2, default: 0.0

      t.timestamps null: false
    end
    add_index :user_incomes, [:resource_type, :user_id]
    add_index :user_incomes, :user_id
  end
end
