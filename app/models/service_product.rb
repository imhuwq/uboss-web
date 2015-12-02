class ServiceProduct < Product
  belongs_to :service_store
  has_many :verify_codes, autosave: true

  validates :service_type, :monthes, presence: true
  validates :service_type, inclusion: { in: [0, 1] }
  validates :monthes, numericality: { greater_than_or_equal_to: 3 }

  DataServiceType = { 0 => '代金券', 1 => '团购' }

  def total_income
    present_price * verify_codes.size
  end
end
