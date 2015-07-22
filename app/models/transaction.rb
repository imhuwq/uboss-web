class Transaction < ActiveRecord::Base

  include Orderable

  belongs_to :user
  belongs_to :source, polymorphic: true

  validates :user_id, :adjust_amount, :current_amount, :source, presence: true

  enum trade_type: { selling: 0, sharing: 1, agent: 2, withdraw: 3 }

  delegate :identify, to: :user, prefix: true, allow_nil: true

end
