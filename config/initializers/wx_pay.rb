
WxPay.appid = Rails.application.secrets.weixin["app_id"]
WxPay.key = Rails.application.secrets.weixin["key_secret"]
WxPay.mch_id = Rails.application.secrets.weixin["app_mchid"]

# optional - configurations for RestClient timeout, etc.
WxPay.extra_rest_client_options = {timeout: 2, open_timeout: 3}
