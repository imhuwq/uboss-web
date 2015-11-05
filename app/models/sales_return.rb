class SalesReturn < ActiveRecord::Base
  belongs_to :order_item_refund
  has_many :asset_imgs, class_name: 'AssetImg', autosave: true, as: :resource
end
