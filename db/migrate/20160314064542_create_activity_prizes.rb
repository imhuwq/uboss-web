class CreateActivityPrizes < ActiveRecord::Migration
  def change
    create_table :activity_prizes do |t|
      t.integer :prize_winner_id
      t.integer :promotion_activity_id
      t.integer :activity_info_id
      t.integer :verify_code_id
      t.jsonb   :info
      t.string  :activity_type
      t.timestamps null: false
    end
    add_column :activity_infos, :draw_count, :integer
  end
end
