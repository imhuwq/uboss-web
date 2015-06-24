class CreateBankCards < ActiveRecord::Migration
  def change
    create_table :bank_cards do |t|
      t.belongs_to :user
      t.string :number
      t.string :name

      t.timestamps null: false
    end

    add_column :withdraw_records, :bank_card_id, :integer

    add_foreign_key :bank_cards, :users
    add_foreign_key :withdraw_records, :bank_cards, on_delete: :nullify
  end
end
