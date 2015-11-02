class OrderItemRefund < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :refund_reason
  has_many :asset_imgs, class_name: 'AssetImg', autosave: true, as: :resource

  def image_files
    self.asset_imgs.map{ |img| img.avatar.file.filename }.join(',')
  end
end
