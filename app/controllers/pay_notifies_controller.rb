class PayNotifiesController < ActionController::Base

  # 支付异步通知
  def wechat_notify
    result = WxPay::Result[Hash.from_xml(request.body.read)]
    Rails.logger.info("weixin notify: #{result}")

    if WxPay::Sign.verify?(result)

      ChargeService.process_paid_result(result: result)

      Rails.logger.info("[SUCCESS] weixin notify: #{result}")

      render xml: {
        return_code: "SUCCESS"
      }.to_xml(root: 'xml', dasherize: false)
    else
      render xml: {
        return_code: "FAIL",
        return_msg: "签名失败"
      }.to_xml(root: 'xml', dasherize: false)
    end
  end

  def wechat_callback
    result = WxPay::Result[Hash.from_xml(request.body.read)].with_indifferent_access
    Rails.logger.info("weixin notify: #{result}")

    if WxPay::Sign.verify?(result)
      unifiedorder = {}
      ActiveRecord::Base.transaction do
        unifiedorder = ChargeService.request_weixin_unifiedorder_for_bill(result)
      end
      render xml: unifiedorder.to_xml(root: 'xml', dasherize: false)
    else
      render xml: {
        return_code: "FAIL",
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
