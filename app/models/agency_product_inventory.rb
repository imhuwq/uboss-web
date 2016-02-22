class AgencyProductInventory < ProductInventory

  validates_numericality_of :price,
    greater_than_or_equal_to: -> (api) { api.parent.suggest_price_lower },
    if: -> { self.parent.suggest_price_lower.present? }
  validates_numericality_of :price,
    less_than_or_equal_to: -> (api) { api.parent.suggest_price_upper },
    if: -> { self.parent.suggest_price_upper.present? }

  belongs_to :parent, class_name: 'SupplierProductInventory'
  belongs_to :agency_product
end
