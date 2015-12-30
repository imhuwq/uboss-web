class AutoSignOrderJob < ActiveJob::Base

  queue_as :auto_sign_order

  include Loggerable

  def perform
    OrdinaryOrder.shiped.where("orders.shiped_at <= ?", Time.now - 9.days).find_each do |ordinary_order|
      sign_order_if_no_refunds(ordinary_order)
    end
  end

  private

  def sign_order_if_no_refunds(ordinary_order)
    return false if ordinary_order.has_refund?

    if ordinary_order.may_sign?
      logger.info "Auto Sign Order SUCCESS, number: #{ordinary_order.number}"
      ordinary_order.sign!
    end
  rescue => e
    logger.error "Auto Sign Order FAIL, number: #{ordinary_order.number}, ERROR: #{e.message}"
    Airbrake.notify_or_ignore(
      e,
      parameters: {order_number: ordinary_order.number},
      cgi_data: ENV.to_hash
    )
  end

end
