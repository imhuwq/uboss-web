class AutoSignOrderJob < ActiveJob::Base

  queue_as :auto_sign_order

  include Loggerable

  def perform
    Order.shiped.where("orders.shiped_at <= ?", Time.now - 9.days).find_each do |order|
      sign_order_if_no_refunds(order)
    end
  end

  private

  def sign_order_if_no_refunds(order)
    return false if order.has_refund?

    if order.may_sign?
      logger.info "Auto Sign Order SUCCESS, number: #{order.number}"
      order.sign!
    end
  rescue => e
    logger.error "Auto Sign Order FAIL, number: #{order.number}, ERROR: #{e.message}"
    Airbrake.notify_or_ignore(
      e,
      parameters: {order_number: order.number},
      cgi_data: ENV.to_hash
    )
  end

end
