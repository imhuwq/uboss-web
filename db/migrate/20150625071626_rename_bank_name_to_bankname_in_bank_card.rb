class RenameBankNameToBanknameInBankCard < ActiveRecord::Migration
  def change
    rename_column :bank_cards, :bank_name, :bankname
  end
end
