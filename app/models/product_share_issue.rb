#encoding:utf-8
class ProductShareIssue < ActiveRecord::Base
	validates :product_id,presence: true
  belongs_to :product

end