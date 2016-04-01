class VerifyCode < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :activity_prize

  before_create :generate_code
  validates_uniqueness_of :code

  default_scope {order("updated_at desc")}

  scope :with_user, ->(user) { joins(order_item: :service_product).merge(user.service_products) }
  scope :today, ->(user) {
    where(verified: true).with_user(user).
    where('verify_codes.updated_at BETWEEN ? AND ?',
          Time.now.beginning_of_day, Time.now.end_of_day) }
  scope :total, ->(user) { where(verified: true).with_user(user) }
  scope :with_activity_user, ->(user) {
    joins(activity_prize:[:promotion_activity]).
    where('promotion_activities.user_id = ?',user.id) }
  scope :activity_today, ->(user) {
    where(verified: true).
    with_activity_user(user).
    where('verify_codes.updated_at BETWEEN ? AND ?',
          Time.now.beginning_of_day, Time.now.end_of_day) }
  scope :activity_total, ->(user) { where(verified: true).with_activity_user(user) }
  scope :activity_noverified_total_for_customer, ->(user) {
    joins(:activity_prize).
    where(verified: false).
    where('activity_prizes.prize_winner_id = ? ', user.id) }

  after_commit :call_verify_code_verified_handler, if: -> {
    previous_changes.include?(:verified) && previous_changes[:verified].last == true
  }

  def self.verify(seller, code)
    result = {}
    verify_code = VerifyCode.find_by(code: code)
    if verify_code && verify_code.order_item_id
      if VerifyCode.with_user(seller).find_by(code: code).verify_code
        result[:success] = true
        result[:message] = "验证成功。"
        result[:verfiy_code] = verify_code
      else
        result[:success] = false
      end
    elsif verify_code && verify_code.activity_prize
      if verify_code.verify_activity_code(seller)
        result[:success] = true
        result[:message] = "#{verify_code.activity_prize.activity_info.name}:验证成功。"
        result[:verfiy_code] = verify_code
      else
        result[:success] = false
      end
    else
      result[:success] = false
    end
    result
  end

  def verify_code
    if !verified && update(verified: true)
      order.try(:check_completed)
      true
    else
      false
    end
  end

  def verify_activity_code(store_admin)
    if activity_prize.promotion_activity.user_id == store_admin.id &&
        !verified && !expired && update(verified: true)
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
      random_number = SecureRandom.random_number(9999999999).to_s
      if random_number.size < 10
        random_number = random_number.center(10, rand(1000000000..9999999999).to_s)
      end
      unless VerifyCode.where(code: random_number).exists?
        self.code = random_number and break
      end
    end
  end

  def call_verify_code_verified_handler
    if order_item_id
      OrderDivideJob.set(wait: 5.seconds).perform_later(self)
    end
  end

end
