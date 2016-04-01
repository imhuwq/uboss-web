class CreateActivityDrawRecord < ActiveRecord::Migration
  def change
    create_table :activity_draw_records do |t|
      t.integer :user_id
      t.integer :sharer_id
      t.integer :promotion_activity_id
      t.integer :activity_info_id
      t.integer :draw_count
    end
  end
end
