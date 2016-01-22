class AddPurchaseNoteToProduct < ActiveRecord::Migration
  def change
    add_column :products, :purchase_note, :text
  end
end
