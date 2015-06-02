#encoding:utf-8
class Product < ActiveRecord::Base
	has_one :asset_img
end