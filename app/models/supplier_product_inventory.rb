class SupplierProductInventory < ProductInventory

  validates_numericality_of :suggest_price_upper, greater_than: :suggest_price_lower,  if: -> { suggest_price_lower.present? }
  validates_numericality_of :suggest_price_lower, greater_than_or_equal_to: :cost_price, if: -> { cost_price.present? }

  belongs_to :supplier_product
  has_many :children, class_name: 'AgencyProductInventory', foreign_key: 'parent_id'

  amoeba do
    customize(lambda{|original_inventory, new_inventory|
      new_inventory.parent_id = original_inventory.id
      new_inventory.type = 'AgencyProductInventory'
      new_inventory.cost_price = original_inventory.price
    })
  end

end
