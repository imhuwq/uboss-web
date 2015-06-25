class RenameNameToUsernameOnBankCards < ActiveRecord::Migration
  def change
    rename_column :bank_cards, :name, :username
  end
end
