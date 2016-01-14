class PurchaseOrder < ActiveRecord::Base
  include AASM
  include Numberable
  belongs_to :order
  has_many :order_items, through: :order
  validates_uniqueness_of :number, allow_blank: true

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed
    state :shiped, before_enter: :update_stock_item
    state :signed
    state :completed
    state :closed

    event :pay do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped
    end
    event :sign do
      transitions from: :shiped, to: :signed
      transitions from: :payed, to: :signed, guards: :single_official_agent?
    end
    event :close do
      transitions from: :unpay, to: :closed
    end
    event :complete do
      transitions from: :signed, to: :completed
    end
  end

  def update_stock_item
  end
end
