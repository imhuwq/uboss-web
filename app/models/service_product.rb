class ServiceProduct < Product
  validates :service_type, :monthes, presence: true
  validates :service_type, inclusion: { in: %w(0 1) }
  validates :monthes, greater_than_or_equal_to: 3
end
