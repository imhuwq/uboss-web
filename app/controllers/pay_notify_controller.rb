class PayNotifyController < ApplicationController

  # 支付异步通知
  def wechat_notify
    result = Hash.from_xml(request.body.read)["xml"]
    Rails.logger.debug("weixin notify: #{result}")

    if WxPay::Sign.verify?(result)

      ChargeService.handle_pay_notify(result)

      render xml: {
        return_code: "SUCCESS"
      }.to_xml(root: 'xml', dasherize: false)
    else
      render xml: {
        return_code: "SUCCESS",
        return_msg: "签名失败"
      }.to_xml(root: 'xml', dasherize: false)
    end
  end

  # 微信警告
  def wechat_alarm
    result = Hash.from_xml(request.body.read)["xml"]
    ServiceNotify.create(service_type: "weixin", content: result)
  end
end
