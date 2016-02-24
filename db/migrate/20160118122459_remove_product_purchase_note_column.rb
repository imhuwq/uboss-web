class RemoveProductPurchaseNoteColumn < ActiveRecord::Migration
  def change
    remove_column :products, :purchase_note, :text
  end
end
