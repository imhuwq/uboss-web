class CreateDailyReports < ActiveRecord::Migration
  def change
    create_table :daily_reports do |t|
      t.date :day
      t.decimal :amount
      t.integer :user_id
      t.integer :report_type

      t.timestamps null: false
    end
  end
end
