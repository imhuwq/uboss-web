class CreateAttentionAssociation < ActiveRecord::Migration
  def change
    create_table :attention_associations do |t|
      t.integer :user_id
      t.integer :following_id
    end
  end
end
