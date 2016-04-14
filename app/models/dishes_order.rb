class DishesOrder < ServiceOrder
  has_one :verify_code, -> { where(target_type: 'DishesOrder') }, foreign_key: :target_id
  validates :order_items,  presence: true
  def present_price
    self.order_items.sum("present_price * amount")
  end

  def paid_and_expensed?
    (completed? || state == 'unevaluate')  && verify_code.verified
  end

  def verified_time
    verify_code.updated_at if verify_code.verified
  end

  def check_completed
    may_complete? && completed!
  end

  def privilege_amount
    @privilege_amount ||= order_items.reduce(0) do |sum, item|
      item.product_inventory.privilege_amount * item.amount
    end
  end

  def share_amount_total
    @share_amount_total ||= order_items.reduce(0) do |sum, item|
      item.product_inventory.share_amount_total * item.amount
    end
  end

  def invoke_service_order_payed_job
    create_verify_code(user_id: self.seller_id)
    ServiceOrderPayedJob.perform_later(self)
  end
end
