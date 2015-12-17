class ServiceProduct < Product
  belongs_to :service_store

  validates :original_price, :present_price, :service_type, :monthes, presence: true
  validates :service_type, inclusion: { in: [0, 1] }
  validates :monthes, numericality: { greater_than_or_equal_to: 3 }

  DataServiceType = { 0 => '代金券', 1 => '团购' }

  after_initialize  :initialize_product_inventory
  before_save :check_service_store_user

  scope :vouchers, -> { where(service_type: 0) }
  scope :groups, -> { where(service_type: 1) }

  def total_sales_volume
    order_items.map(&:amount).sum
  end

  def total_income
    present_price * total_sales_volume
  end

  def deadline
    created_at + monthes.months
  end

  private

  def initialize_product_inventory
    if self.new_record?
      self.product_inventories.new(
        price: self.present_price,
        count: self.count,
        sku_attributes: { '其它' => '默认' }
      )
    end
  end

  def check_service_store_user
    self.service_store.user_id == self.user_id
  end
end
