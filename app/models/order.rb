class Order < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :seller, class_name: "User"
  has_many :order_items

  accepts_nested_attributes_for :order_items

  validates :number, :user, :address, presence: true
  validates_uniqueness_of :number

  before_validation :set_number, on: :create

  delegate :mobile, :regist_mobile, to: :user, prefix: :buyer

  scope :today, -> { where('created_at >= ?', Time.now.beginning_of_day) }
  scope :selled, -> { where('state <> 0') }

  enum state: { unpay: 0, payed: 1, shiped: 3, signed: 4, closed: 5 }

  aasm column: :state, enum: true, skip_validation_on_save: true do
    state :unpay
    state :payed
    state :shiped
    state :signed
    state :closed

    event :pay do
      transitions from: :unpay, to: :payed
    end
    event :ship do
      transitions from: :payed, to: :shiped 
    end
    event :signed do
      transitions from: :shiped, to: :signed 
    end
    event :close do
      transitions from: :unpay, to: :closed 
    end
  end

  private

  def set_number
    # TODO more friendly
    self.number = "#{Time.now.to_number(:nsec)}"
  end

end
