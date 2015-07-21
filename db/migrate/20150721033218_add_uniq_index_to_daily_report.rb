class AddUniqIndexToDailyReport < ActiveRecord::Migration
  def change
    add_column :daily_reports, :uniq_identify, :string

    add_index :daily_reports, :uniq_identify, unique: true
  end
end
