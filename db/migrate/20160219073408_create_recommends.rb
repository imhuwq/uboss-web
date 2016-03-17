class CreateRecommends < ActiveRecord::Migration
  def change
    create_table :recommends do |t|
      t.integer :user_id
      t.integer :recommended_id
      t.string :recommended_type

      t.timestamps null: false
    end
  end
end
