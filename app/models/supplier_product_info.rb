class SupplierProductInfo < ActiveRecord::Base
  include Descriptiontable
  belongs_to :product
  belongs_to :supplier, class_name: 'User'
end
