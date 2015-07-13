WxPay.appid = Rails.application.secrets.weixin["app_id"]
WxPay.key = Rails.application.secrets.weixin["key_secret"]
WxPay.mch_id = Rails.application.secrets.weixin["app_mchid"]

p12 = OpenSSL::PKCS12.new(
  File.read(File.join(Rails.root, 'config/apiclient_cert.p12')),
  WxPay.mch_id
)

WxPay.client_cert = p12.certificate
WxPay.client_key = p12.key

# optional - configurations for RestClient timeout, etc.
WxPay.extra_rest_client_options = {timeout: 10, open_timeout: 10}
