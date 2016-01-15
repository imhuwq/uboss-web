class SupplierProduct < Product

  has_one :supplier_product_info, foreign_key: 'supplier_product_id'
  has_one :supplier, through: :supplier_product_info
  has_many :supplier_product_inventories

  amoeba do
    include_association :categories
    include_association :supplier_product_info
  end

  delegate :cost_price, :cost_price=, to: :supplier_product_info, allow_nil: true
  delegate :suggest_price_lower, :suggest_price_lower=, to: :supplier_product_info, allow_nil: true
  delegate :suggest_price_upper, :suggest_price_upper=, to: :supplier_product_info, allow_nil: true
  delegate :supplier_id, :supplier_id=, to: :supplier_product_info, allow_nil: true
  delegate :content, :content=, to: 'supplier_product_info.description', prefix: 'supplier_des'

  scope :supply_stored, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 0') }
  scope :supply_supplied, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 1') }
  scope :supply_deleted, -> { joins(:supplier_product_info).where('supplier_product_infos.supply_status = 2') }

end
