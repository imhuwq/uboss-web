class DishesOrder < Order
  has_one :verify_code
  enum state: { unpay: 0, payed: 1, closed: 5, completed: 6 }

  scope :has_payed, -> { where(state: [1, 6]) }

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed
    state :completed
    state :closed

    event :pay do
      transitions from: :unpay, to: :payed
    end
    event :close do
      transitions from: :unpay, to: :closed
    end
    event :complete do
      transitions from: :payed, to: :completed
    end
  end

end
