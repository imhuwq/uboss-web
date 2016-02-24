class AddActivedToBonusRecords < ActiveRecord::Migration
  def change
    add_column :bonus_records, :actived, :boolean
  end
end
