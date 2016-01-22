class CreateWxScenes < ActiveRecord::Migration
  def change
    create_table :wx_scenes do |t|
      t.datetime :expire_at
      t.string   :scene_str
      t.string   :scene_id
      t.jsonb    :properties, default: {}

      t.timestamps null: false
    end
  end
end
