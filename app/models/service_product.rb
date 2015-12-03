class ServiceProduct < Product
  belongs_to :service_store
  has_many :verify_codes, autosave: true

  validates :original_price, :present_price, :service_type, :monthes, presence: true
  validates :service_type, inclusion: { in: [0, 1] }
  validates :monthes, numericality: { greater_than_or_equal_to: 3 }

  DataServiceType = { 0 => '代金券', 1 => '团购' }

  before_validation :set_default_product_inventory

  def total_income
    present_price * verify_codes.size
  end

  private

  def set_default_product_inventory
    if self.new_record?
      self.product_inventories.new(
        price: self.present_price,
        count: self.count,
        sku_attributes: { '其它' => '默认' }
      )
    end
  end
end
