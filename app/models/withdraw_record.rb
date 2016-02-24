class WithdrawRecord < ActiveRecord::Base

  include AASM
  include Orderable
  include Numberable

  class AdjuestUserIncomeTypeWrong < StandardError;;end

  BANK_INFO_STORE_KEYS = [:username, :bankname, :number]

  attr_accessor :transfer_remote_ip

  serialize :bank_info
  serialize :error_info

  belongs_to :user
  belongs_to :bank_card

  validates :user_id, :amount, presence: true
  validates_numericality_of :amount, greater_than_or_equal_to: 1
  validates_numericality_of :amount,
    less_than_or_equal_to: ->(record) { record.user.income.to_f },
    if: :new_record?
  validates :bank_card_id, presence: { message: '未创建且账号未绑定微信' }, if: -> { user.weixin_openid.blank? }
  validate  :seller_must_be_authenticated, if: -> { user.is_seller? }

  delegate :identify, :total_income, to: :user, prefix: true

  enum state: { unprocess: 0, processed: 1, done: 2, closed: 3, failure: 4 }

  before_save :set_bank_info
  after_create :decrease_user_income

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unprocess
    state :processed, before_enter: :set_processed_info
    state :done, before_enter: :set_done_at, after_enter: [:remove_user_frozen_income, :record_trade]
    state :failure
    state :closed, after_enter: :recover_user_income

    event :process, after_commit: :delay_transfer_money do
      transitions from: :unprocess, to: :processed
      transitions from: :failure, to: :processed
    end

    event :fail do
      transitions from: :processed, to: :failure
    end

    event :finish do
      transitions from: :processed, to: :done
      transitions from: :failure, to: :done
    end

    event :close do
      transitions from: :unprocess, to: :closed
    end
  end

  BANK_INFO_STORE_KEYS.each do |key|
    define_method "card_#{key}" do
      bank_info.respond_to?(:[], key) ? bank_info[key] : nil
    end
  end

  def wechat_available?
    bank_info.blank? && user.weixin_openid.present?
  end

  def bank_processing?
    bank_info.present?
  end

  def target_title
    wechat_available? ? "微信" : card_bankname
  end

  def target_content
    wechat_available? ? user.weixin_openid : card_number
  end

  def delay_query_wx_transfer
    self.update_error_info(requerying_at: Time.now, requerying_done_at: nil)
    WithdrawJob.perform_later(self, type: 'query')
  end

  def update_error_info(info)
    info = (error_info || {}).merge(info)
    update_columns(error_info: info.merge(msg_updated_at: Time.now))
  end

  private

  def seller_must_be_authenticated
    errors.add(:base, '您还未认证您的商家身份') if user.authenticated == 'no'
  end

  def delay_transfer_money
    if wechat_available?
      WithdrawJob.perform_later(self, ip: self.transfer_remote_ip)
    end
  end

  def set_bank_info
    if bank_card_id_changed? && bank_card_id.present?
      self.bank_info = {}
      BANK_INFO_STORE_KEYS.each do |key|
        self.bank_info[key] = bank_card[key]
      end
    end
  end

  def set_processed_info
    touch(:process_at)
  end

  def set_done_at
    touch(:done_at)
  end

  def decrease_user_income
    adjust_user_income(:dec)
  end

  def recover_user_income
    adjust_user_income(:inc)
  end

  def adjust_user_income(type)
    if [:inc, :dec].include?(type)
      type = (type == :inc) ? 1 : -1
      UserInfo.update_counters(user.user_info.id, income: amount * type, frozen_income: -amount * type)
    else
      raise AdjuestUserIncomeTypeWrong, "Type: #{type} is worong, accept is :inc or :dec"
    end
  end

  def remove_user_frozen_income
    UserInfo.update_counters(user.user_info.id, frozen_income: -amount)
  end

  def record_trade
    Transaction.create!(
      user: user,
      source: self,
      adjust_amount: -amount,
      current_amount: user.income,
      trade_type: 'withdraw'
    )
  end

end
