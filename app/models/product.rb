#encoding:utf-8
class Product < ActiveRecord::Base

  DataPresentWay = {0=>'现金',1=>'产品'}
  DataBuyerPay = {true=>"买家付款",false=>"卖家付款"}

  validates_presence_of :user_id,:name

	has_one  :asset_img, :class_name => "AssetImg",dependent: :destroy,as: :resource
  has_many  :product_share_issue, :dependent=>:destroy

  before_create :generate_code
  def generate_code
    self.code = UUIDTools::UUID.random_create.to_s.gsub!('-','')
  end
end