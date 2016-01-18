class VerifyCode < ActiveRecord::Base
  belongs_to :order_item

  before_create :generate_code
  validates_uniqueness_of :code

  default_scope {order("updated_at desc")}

  scope :with_user, ->(user) { joins(order_item: :service_product).merge(user.service_products) }
  scope :today, ->(user) { where(verified: true).with_user(user).
                           where('verify_codes.updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, Time.now.end_of_day) }
  scope :total, ->(user) { where(verified: true).with_user(user) }

  after_commit :call_verify_code_verified_handler, if: -> {
    previous_changes.include?(:verified) && previous_changes[:verified].last == true
  }

  def verify_code
    if !verified && update(verified: true)
      order.try(:check_completed)
      true
    else
      false
    end
  end

  def order
    order_item.order
  end

  def verify_time
    updated_at.strftime("%H : %M")
  end

  private

  def generate_code
    loop do
      tmp_number = SecureRandom.random_number(100000000000).to_s.center(10, rand(9).to_s)
      unless VerifyCode.find_by(code: tmp_number)
        self.code = tmp_number and break
      end
    end
  end

  def call_verify_code_verified_handler
    OrderDivideJob.set(wait: 5.seconds).perform_later(self)
  end

end
