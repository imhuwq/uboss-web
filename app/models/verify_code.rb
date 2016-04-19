class VerifyCode < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :user
  belongs_to :activity_prize

  before_create :generate_code
  validates_uniqueness_of :code

  default_scope {order("updated_at desc")}

  scope :with_user, ->(user) { user.verify_codes }

  scope :today, ->(user) {
    with_user(user).where(verified: true).
    where('verify_codes.updated_at BETWEEN ? AND ?',
          Time.now.beginning_of_day, Time.now.end_of_day) }

  scope :total, ->(user) { with_user(user).where(verified: true) }

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
    if verify_code && verify_code.target_type == 'OrderItem'
      result[:success] = VerifyCode.with_user(seller).find_by(code: code).verify_code
      if result[:success] == true
        result[:verfiy_code] = verify_code
      end
    elsif verify_code && verify_code.target_type == 'DishesOrder'
      result[:success] = VerifyCode.with_user(seller).find_by(code: code).verify_code
      if result[:success] == true
        result[:verfiy_code] = verify_code
      end
    elsif verify_code && verify_code.activity_prize
      result[:success] =  verify_code.verify_activity_code(seller)
      if result[:success] == true
        result[:verfiy_code] = verify_code
      end
    else
      result[:success] = false
      result[:message] = "无效的验证码"
    end
    result
  end

  def verify_code
     if !verified && update(verified: true)
       if target_type == 'DishesOrder'
         target.try(:check_completed)
       else
         target.order.try(:check_completed)
       end
       true
     else
       false
     end
   end

  def verify_activity_code(store_admin)
    if activity_prize.promotion_activity.user_id != store_admin.id
      return {success: false, message: "#{activity_prize.activity_info.name}:你不是本活动的创建者。"}
    elsif verified
      return {success: false, message: "#{activity_prize.activity_info.name}:已经使用过了。"}
    elsif expired
      return {success: false, message: "#{activity_prize.activity_info.name}:已经过期了。"}
    elsif update(verified: true)
      return {success: true, message: "#{activity_prize.activity_info.name}:验证成功。"}
    end
  end

  def order
    if target_type == 'OrderItem'
      target.order
    else
      self
    end
  end

  def order_item
    if target_type == 'OrderItem'
      target
    end
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
    arg = case self.target_type
    when 'OrderItem' then self
    when 'DishesOrder' then target
    end
    OrderDivideJob.set(wait: 5.seconds).perform_later(arg) if arg
  end

end
