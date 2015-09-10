class CreateAttentions < ActiveRecord::Migration
  def change
    create_table :attentions do |t|
      t.integer :follower_id
      t.integer :following_id

      t.timestamps null: false
    end
  end
end
