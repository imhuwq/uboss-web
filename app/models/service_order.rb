class ServiceOrder < Order
  has_many :verify_codes, through: :order_items

  enum state: { unpay: 0, payed: 1, closed: 2, completed: 3 }

  aasm column: :state, enum: true, skip_validation_on_save: true, whiny_transitions: false do
    state :unpay
    state :payed,     after_enter: [:invoke_service_order_payed_job, :create_verify_code]
    state :completed, after_enter: :fill_completed_at
    state :closed,    after_enter: :recover_product_stock

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

  def order_item
    order_items.first
  end

  def check_completed
    if VerifyCode.where(order_item_id: self.order_item_ids, verified: false).blank?
      may_complete? && completed!
    end
  end

  private

  def invoke_service_order_payed_job
    #ServiceOrderPayedJob.perform_later(self)
    create_privilege_card_if_none
  end

  def create_privilege_card_if_none
    PrivilegeCard.find_or_active_card(user_id, seller.id)
  end

  def create_verify_code
    order_items.each { |order_item| order_item.amount.times { order_item.verify_codes.create!() } }
  end

end
