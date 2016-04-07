class DishesOrder < ServiceOrder
  has_one :verify_code

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
    create_verify_code
    ServiceOrderPayedJob.perform_later(self)
  end
end
