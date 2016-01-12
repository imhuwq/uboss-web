class SupplierProductInfo < ActiveRecord::Base

  include Descriptiontable

  enum supply_status: [:stored, :supplied, :deleted]

  validates :cost_price, presence: true, numericality: { greater_than: 0 }
  validates :suggest_price_lower, :suggest_price_upper, numericality: { greater_than: 0, allow_nil: true }

  belongs_to :product
  belongs_to :supplier, class_name: 'User'

end
