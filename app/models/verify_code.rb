class VerifyCode < ActiveRecord::Base
  belongs_to :service_product

  validates_uniqueness_of :code

  default_scope {order("updated_at desc")}

  scope :today, -> { where(verified: true).where('updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, DateTime.now.end_of_day) }
  scope :total, -> { where(verified: true) }

  def generate_code
    self.code = SecureRandom.random_number(100000000000)
  end

  def verify_code
    update(verified: true) if !verified
  end
end
