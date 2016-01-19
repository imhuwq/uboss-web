class PurchaseOrder < ActiveRecord::Base
  include AASM
  include Numberable
  belongs_to :order
  belongs_to :seller, class_name: 'User'
  has_many :order_items, through: :order
  validates_uniqueness_of :number, allow_blank: true

  scope :today, -> (date=Date.today) { where(['DATE(purchase_orders.created_at) = ?', date]) }
  scope :week, -> (time=Time.now) { where(created_at: time.beginning_of_week..time.end_of_week) }
  scope :month, -> (time=Time.now) { where(created_at: time.beginning_of_month..time.end_of_month) }

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5, completed: 6 }

  aasm column: :state, enum: true do
    state :unpay
    state :payed
    state :shiped
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
      transitions from: [:payed, :shiped], to: :signed
    end
    event :close do
      transitions from: :unpay, to: :closed, after: -> { order.close }
    end
    event :complete do
      transitions from: :signed, to: :completed
    end
  end

  # def shipment_ordinary_order
  #   order.ship
  # end
end
