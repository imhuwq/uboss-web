class ServiceOrder < Order
  enum state: { unpay: 0, payed: 1, expensed: 2, closed: 3, completed: 4 }

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed,     after_enter: :invoke_service_order_payed_job
    state :expensed
    state :completed, after_enter: :fill_completed_at
    state :closed,    after_enter: :recover_product_stock

    event :pay do
      transitions from: :unpay, to: :payed
    end
    event :expensed do
      transitions from: :payed, to: :expensed
    end
    event :close do
      transitions from: :unpay, to: :closed
    end
    event :complete do
      transitions from: :payed, to: :completed
    end
  end

  private

  def invoke_service_order_payed_job
    #ServiceOrderPayedJob.perform_later(self)
  end

end
