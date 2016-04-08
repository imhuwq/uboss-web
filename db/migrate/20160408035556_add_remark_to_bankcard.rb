class AddRemarkToBankcard < ActiveRecord::Migration
  def change
    add_column :bank_cards, :remark, :string
  end
end
