require 'wx_pay_ext'

$wechat_env = ActiveSupport::StringInquirer.new(ENV['WECHAT_ENV'] || 'production')

if $wechat_env.test?
  p "NOTE! wechat test model enabled, any pay request is FAKE!"
end

WxPay.appid = Rails.application.secrets.weixin["app_id"]
WxPay.key = Rails.application.secrets.weixin["key_secret"]
WxPay.mch_id = Rails.application.secrets.weixin["app_mchid"]

if File.exists?(File.join(Rails.root, 'config/apiclient_cert.p12'))
  WxPay.apiclient_cert_path = File.read("#{Rails.root}/config/apiclient_cert.p12")
else
  p "WARN! There is no apiclient_cert.p12 file for wechat, some api will fail!"
end

# optional - configurations for RestClient timeout, etc.
WxPay.extra_rest_client_options = { timeout: 10, open_timeout: 10 }
