class CreateActivityInfos < ActiveRecord::Migration
  def change
    create_table :activity_infos do |t|
      t.references :promotion_activity, index: true, foreign_key: true
      t.string  :activity_type
      t.string  :name
      t.decimal :price,        default: 0.0
      t.integer :expiry_days,  default: 0
      t.string  :description
      t.integer :win_count,    default: 0
      t.integer :win_rate,     default: 0

      t.timestamps null: false
    end
  end
end
