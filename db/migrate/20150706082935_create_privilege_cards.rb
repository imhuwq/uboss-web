class CreatePrivilegeCards < ActiveRecord::Migration
  def change
    create_table :privilege_cards do |t|
      t.belongs_to :product
      t.belongs_to :user
      t.float :amount, default: 0

      t.timestamps null: false
    end

    add_foreign_key :privilege_cards, :products
    add_foreign_key :privilege_cards, :users
  end
end
