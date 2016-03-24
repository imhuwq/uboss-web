class DishesOrder < ServiceOrder
  has_one :verify_code

  def invoke_service_order_payed_job
    create_verify_code
    ServiceOrderPayedJob.perform_later(self)
  end
end
