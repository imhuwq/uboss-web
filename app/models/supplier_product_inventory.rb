class SupplierProductInventory < ProductInventory

  has_one :supplier_product_inventory_info, foreign_key: 'supplier_product_inventory_id', autosave: true, dependent: :destroy

  delegate :cost_price, :cost_price=, to: :supplier_product_inventory, allow_nil: true
  delegate :suggest_price_lower, :suggest_price_lower=, to: :supplier_product_inventory, allow_nil: true
  delegate :suggest_price_upper, :suggest_price_upper=, to: :supplier_product_inventory, allow_nil: true
  delegate :for_sale, :for_sale=, to: :supplier_product_inventory, allow_nil: true
  delegate :quantity, :quantity=, to: :supplier_product_inventory, allow_nil: true

end
