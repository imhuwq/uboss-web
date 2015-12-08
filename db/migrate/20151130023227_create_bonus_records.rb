class CreateBonusRecords < ActiveRecord::Migration
  def change
    create_table :bonus_records do |t|
      t.decimal :amount

      t.timestamps null: false
    end
  end
end
