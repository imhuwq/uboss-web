class VerifyCode < ActiveRecord::Base
  belongs_to :order_item
  belongs_to :activity_prize

  before_create :generate_code
  validates_uniqueness_of :code

  default_scope {order("updated_at desc")}

  scope :with_user, ->(user) { joins(order_item: :service_product).merge(user.service_products) }
  scope :today, ->(user) { where(verified: true).with_user(user).
                           where('verify_codes.updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, Time.now.end_of_day) }
  scope :total, ->(user) { where(verified: true).with_user(user) }


  # scope :with_activity_user, ->(user) { joins('inner join activity_prizes on verify_codes.activity_prize_id=activity_prizes.id').
  #                             where(' activity_prizes.prize_winner_id = ?',user.id) }
  scope :with_activity_user, ->(user) { ids = user.promotion_activities.published.collect(&:activity_infos).
                                        flatten.collect(&:activity_prize).flatten.collect(&:id)
                                        where(activity_prize_id: ids)}
  scope :activity_today, ->(user) { where(verified: true).with_activity_user(user).
                           where('verify_codes.updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, Time.now.end_of_day) }
  scope :activity_total, ->(user) { where(verified: true).with_activity_user(user) }
  scope :activity_noverified_total, ->(user) { where(verified: false).with_activity_user(user) }

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

  def verify_activity_code(store_admin)
    if activity_prize.promotion_activity.user.id == store_admin.id && !verified && !expired && update(verified: true)
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
