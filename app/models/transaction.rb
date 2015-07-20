class Transaction < ActiveRecord::Base

  belongs_to :users
  belongs_to :source, polymorphic: true

  validates :user_id, :adjust_amount, :current_amount, :source, presence: true

  enum :trade_type, { order: 0, sharing: 1, agent: 2, withdraw: 3 }

  def self.record_trade(user, source, adjust_amount, current_amount, trade_type)
    create!(
      user_id: user.is_a?(User) ? user.id : user,
      source: source,
      adjust_amount: adjust_amount,
      current_amount: current_amount,
      trade_type: trade_type
    )
  end

end
