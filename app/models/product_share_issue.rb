#encoding:utf-8
class ProductShareIssue < ActiveRecord::Base
	validate_present_of :product_id
  belongs_to :product

end