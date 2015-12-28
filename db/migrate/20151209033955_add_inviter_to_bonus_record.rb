class AddInviterToBonusRecord < ActiveRecord::Migration
  def change
    add_column :bonus_records, :inviter_id, :integer
  end
end
