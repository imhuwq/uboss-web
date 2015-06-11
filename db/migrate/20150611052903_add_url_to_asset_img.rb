class AddUrlToAssetImg < ActiveRecord::Migration
  def change
    add_column :asset_imgs, :url, :string
  end
end
