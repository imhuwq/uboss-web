class CreateAssetImg < ActiveRecord::Migration
  def change
    create_table "asset_imgs", :force => true do |t|
      t.string   :filename
      t.string   :avatar
      t.string   :content_type
      t.string   :resource_type, :limit => 50
      t.integer  :resource_id
      t.integer  :size
      t.integer  :width
      t.integer  :height
      t.integer  :parent_id
      t.string   :thumbnail
      t.datetime :created_at
      t.string   :alt
    end
  end
end
