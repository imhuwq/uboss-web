class CreateFollowerAssociation < ActiveRecord::Migration
  def change
    create_table :follower_associations do |t|
      t.integer :user_id
      t.integer :follower_id
    end
  end
end
