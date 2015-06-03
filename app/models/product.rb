#encoding:utf-8
class Product < ActiveRecord::Base
  DataPresentWay = {0=>'整取',1=>'零取'}
	has_one :asset_img
end