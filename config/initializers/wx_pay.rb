module WxPay
  module Service

    GENERATE_ORDERQUERY_REQUIRED_FIELDS = %i(out_trade_no nonce_str)
    def self.invoke_orderquery(params)
      params = {
        appid: WxPay.appid,
        mch_id: WxPay.mch_id
      }.merge(params)

      check_required_options(params, GENERATE_ORDERQUERY_REQUIRED_FIELDS)

      r = invoke_remote("#{GATEWAY_URL}/orderquery", make_payload(params))

      yield r if block_given?

      r
    end

  end
end

WxPay.appid = Rails.application.secrets.weixin["app_id"]
WxPay.key = Rails.application.secrets.weixin["key_secret"]
WxPay.mch_id = Rails.application.secrets.weixin["app_mchid"]

# optional - configurations for RestClient timeout, etc.
WxPay.extra_rest_client_options = {timeout: 10, open_timeout: 10}
