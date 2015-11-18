class WxOrderCloseJob < ActiveJob::Base
  queue_as :default

  def perform(order_number)
    tries ||= 3
    res = WxPay::Service.invoke_closeorder({out_trade_no: order_number})
    raise unless res.success?
  rescue
    tries -= 1
    tries > 0 ? retry : logger.info(res)
  end

end
