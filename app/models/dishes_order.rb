class DishesOrder < ServiceOrder
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
    order_item.verify_codes.create!()
    ServiceOrderPayedJob.perform_later(self)
  end

  def verify_code
    order_item.verify_code
  end
end
