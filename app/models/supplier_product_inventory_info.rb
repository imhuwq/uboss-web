class SupplierProductInventoryInfo < ActiveRecord::Base
  belongs_to :supplier_product_inventory
  belongs_to :product

  validates :cost_price, presence: true, numericality: { greater_than: 0 }
  #validates :suggest_price_lower, :suggest_price_upper, numericality: { greater_than: 0, allow_nil: true }
end
