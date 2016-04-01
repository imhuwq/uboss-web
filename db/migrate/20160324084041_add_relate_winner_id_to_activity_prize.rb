class AddRelateWinnerIdToActivityPrize < ActiveRecord::Migration
  def change
    add_column :activity_prizes, :relate_winner_id, :integer
    remove_column :activity_infos,  :win_rate, :integer, default: 1
    add_column :activity_infos,  :win_rate, :float, default: 1
  end
end
