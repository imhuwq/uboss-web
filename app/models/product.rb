#encoding:utf-8
class Product < ActiveRecord::Base
  DataPresentWay = {0=>'现金',1=>'产品'}
  DataBuyerPay = {true=>"买家付款",false=>"卖家付款"}
  attr_accessor :product_id,:buyer_lv_1,:buyer_lv_2,:buyer_lv_3,:sharer_lv_1,:buyer_present_way,
                :sharer_present_way,:buyer_pay,:traffic_expense
	has_one   :asset_img
  has_many  :product_share_issue, :dependent=>:destroy
end
