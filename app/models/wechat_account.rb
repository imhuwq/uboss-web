class WechatAccount < ActiveRecord::Base

  # It will auto generate weixin token and secret
  include WeixinRailsMiddleware::AutoGenerateWeixinTokenSecretKey
  include Orderable

  validates_presence_of :name
  validates_uniqueness_of :weixin_secret_key

  # never show real app_secret
  def app_secret
    @app_secret ||= if self.encoding_app_secret.present?
                      CryptService.decrypt(self.encoding_app_secret)
                    end
  end

  def app_secret=(secret)
    if secret.present?
      write_attribute(:encoding_app_secret, CryptService.encrypt(secret))
    end
    @app_secret = secret
  end

end
