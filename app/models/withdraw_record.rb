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
  validates_numericality_of :amount, greater_than_or_equal_to: 100
  validates_numericality_of :amount,
    less_than_or_equal_to: ->(record) { record.user.income.to_f },
    if: :new_record?
  validates :bank_card_id, presence: true, if: -> { user.weixin_openid.blank? }

  delegate :identify, :total_income, to: :user, prefix: true

  enum state: { unprocess: 0, processed: 1, done: 2, closed: 3 }

  before_save :set_bank_info
  after_create :decrease_user_income

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unprocess
    state :processed, before_enter: :set_processed_info
    state :done, before_enter: :set_done_at, after_enter: [:remove_user_frozen_income, :record_trade]
    state :closed, after_enter: :recover_user_income

    event :process, after_commit: :delay_transfer_money do
      transitions from: :unprocess, to: :processed
    end

    event :finish do
      transitions from: :processed, to: :done
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

  private

  def delay_transfer_money
    if wechat_available?
      WithdrawJob.perform_later(self, self.transfer_remote_ip)
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
