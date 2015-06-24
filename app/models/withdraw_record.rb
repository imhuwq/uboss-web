class WithdrawRecord < ActiveRecord::Base

  serialize :bank_info

  belongs_to :user
  belongs_to :bank_card

  validates :user_id, :bank_card_id, :state, :amount, presence: true
  validates_numericality_of :amount, greater_than: 0,
    less_than: -> (withdraw) { withdraw.user.income.to_f }

  enum state: { unprocess: 0, processed: 1, done: 2, closed: 3 }

  before_save :set_bank_info
  after_create :handle_user_income

  aasm column: :state, enum: true do
    state :unprocess
    state :processed, after: :set_processed_info
    state :done, after: :set_done_at
    state :closed

    event :process do
      transitions from: :unprocess, to: :process
    end

    event :finish do
      transitions from: :process, to: :done
    end

    event :close do
      transitions from: :unprocess, to: :closed
    end
  end


  private
  def set_bank_info
    self.bank_info = { number: bank_card.number, name: bank_card.name }
  end

  def set_processed_info
    self.processed_at = DateTime.now
  end

  def set_closed_info
    self.done_at = DateTime.now
  end

  def handle_user_income
    UserInfo.update_counters(user.user_info.id, income: -amount, frozen_income: amount)
  end

end
