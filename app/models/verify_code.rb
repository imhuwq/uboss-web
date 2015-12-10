class VerifyCode < ActiveRecord::Base
  belongs_to :order_item

  before_create :generate_code
  validates_uniqueness_of :code

  default_scope {order("updated_at desc")}

  scope :today, ->(user) { where(verified: true, order_item_id: OrderItem.where(product_id: user.product_ids).ids).where('updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, Time.now.end_of_day) }

  scope :total, ->(user) { where(verified: true, order_item_id: OrderItem.where(product_id: user.product_ids).ids) }

  def verify_code
    update(verified: true) if !verified
  end

  private
  def generate_code
    self.code = SecureRandom.random_number(100000000000)
  end
end
