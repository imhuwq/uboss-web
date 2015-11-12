class AddImageTypeToAssetImg < ActiveRecord::Migration
  def change
    add_column :asset_imgs, :image_type, :string
  end
end
