class WithdrawRecord < ActiveRecord::Base

  include AASM
  include Orderable
  include Numberable

  class AdjuestUserIncomeTypeWrong < StandardError;;end

  BANK_INFO_STORE_KEYS = [:username, :bankname, :number]

  serialize :bank_info

  belongs_to :user
  belongs_to :bank_card

  validates :user_id, :bank_card_id, :amount, presence: true
  validates_numericality_of :amount, greater_than: 0
  validates_numericality_of :amount,
    less_or_equal_than: -> (withdraw) { withdraw.user.income.to_f },
    if: :new_record?

  delegate :identify, to: :user, prefix: true

  enum state: { unprocess: 0, processed: 1, done: 2, closed: 3 }

  before_save :set_bank_info
  after_create :handle_user_income

  aasm column: :state, enum: true do
    state :unprocess
    state :processed, before_enter: :set_processed_info
    state :done, before_enter: :set_done_at, after_enter: :remove_user_frozen_income
    state :closed, after_enter: :recover_user_income

    event :process do
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
      bank_info[key]
    end
  end

  private

  def set_bank_info
    if bank_card_id_changed?
      self.bank_info = {}
      BANK_INFO_STORE_KEYS.each do |key|
        self.bank_info[key] = bank_card[key]
      end
    end
  end

  def set_processed_info
    self.process_at = DateTime.now
  end

  def set_done_at
    self.done_at = DateTime.now
  end

  def handle_user_income
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

end
