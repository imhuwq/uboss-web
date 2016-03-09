class AgencyProductInventory < ProductInventory

  validates_numericality_of :price,
    greater_than_or_equal_to: -> (api) { api.parent.suggest_price_lower },
    if: -> { self.parent.suggest_price_lower.present? }
  validates_numericality_of :price,
    less_than_or_equal_to: -> (api) { api.parent.suggest_price_upper },
    if: -> { self.parent.suggest_price_upper.present? }

  before_save :check_sale_to_agency

  belongs_to :parent, class_name: 'SupplierProductInventory'
  belongs_to :agency_product

  delegate :sale_to_agency, to: :parent
  delegate :cost_price, to: :parent
  delegate :suggest_price_lower, to: :parent
  delegate :suggest_price_upper, to: :parent

  private

  def check_sale_to_agency
    unless sale_to_agency
      return false
    end
  end
    
end
