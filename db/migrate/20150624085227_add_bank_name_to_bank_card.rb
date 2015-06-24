class AddBankNameToBankCard < ActiveRecord::Migration
  def change
    add_column :bank_cards, :bank_name, :string
  end
end
