class CreateSharingIncomes < ActiveRecord::Migration
  def change
    create_table :sharing_incomes do |t|
      t.belongs_to :user
      t.belongs_to :seller
      t.belongs_to :sharing_node
      t.belongs_to :order_item

      t.float :amount

      t.timestamps null: false
    end
    
    add_foreign_key :sharing_incomes, :users
    add_foreign_key :sharing_incomes, :users, column: :seller_id
    add_foreign_key :sharing_incomes, :order_items
  end
end
