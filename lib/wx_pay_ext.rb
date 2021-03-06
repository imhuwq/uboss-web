require 'active_support/concern'

module WxPayExt
  extend ActiveSupport::Concern

  module ClassMethods
    GATEWAY_URL = 'https://api.mch.weixin.qq.com'

    INVOKE_CLOSEORDER_REQUIRED_FIELDS = %i(out_trade_no)
    def invoke_closeorder params
      params = {
        appid: WxPay.appid,
        mch_id: WxPay.mch_id,
        nonce_str: SecureRandom.uuid.tr('-', '')
      }.merge(params)

      check_required_options(params, INVOKE_CLOSEORDER_REQUIRED_FIELDS)

      r = invoke_remote "#{GATEWAY_URL}/pay/closeorder", make_payload(params)

      yield r if block_given?

      r
    end

    INVOKE_REFUNDQUERY_REQUIRED_FIELDS = %i(out_refund_no)
    def invoke_refundquery(params)
      params = {
        appid: WxPay.appid,
        mch_id: WxPay.mch_id,
        nonce_str: SecureRandom.uuid.tr('-', '')
      }.merge(params)

      check_required_options(params, INVOKE_REFUNDQUERY_REQUIRED_FIELDS)

      r = invoke_remote_with_cert("#{GATEWAY_URL}/pay/refundquery", make_payload(params))

      yield r if block_given?

      r
    end

    INVOKE_TRANSFERQUERY_REQUIRED_FIELDS = %i(partner_trade_no)
    def invoke_transferquery(params)
      params = {
        appid: WxPay.appid,
        mch_id: WxPay.mch_id,
        nonce_str: SecureRandom.uuid.tr('-', '')
      }.merge(params)

      check_required_options(params, INVOKE_TRANSFERQUERY_REQUIRED_FIELDS)

      r = invoke_remote_with_cert("#{GATEWAY_URL}/mmpaymkttransfers/gettransferinfo", make_payload(params))

      yield r if block_given?

      r
    end
  end

end

WxPay::Service.send :include, WxPayExt
