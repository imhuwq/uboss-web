class WechatAccount < ActiveRecord::Base

  # It will auto generate weixin token and secret
  include WeixinRailsMiddleware::AutoGenerateWeixinTokenSecretKey
  include Orderable

  validates_presence_of :name
  validates_uniqueness_of :weixin_secret_key

  def self.get_wexin_client(options)
    if options[:wechat_identify].present? && $weixin_clients[options[:wechat_identify]].present?
      return $weixin_clients[options[:wechat_identify]]
    end

    if options[:wechat_account] && $weixin_clients[options[:wechat_account].wechat_identify].present?
      return $weixin_clients[options[:wechat_account].wechat_identify]
    end

    wechat_account = options.fetch(:wechat_account) do
      find_by(wechat_identify: options[:wechat_identify])
    end

    return nil if wechat_account.blank?

    $weixin_clients[wechat_account.wechat_identify] ||= WeixinAuthorize::Client.new(
      wechat_account.app_id,
      wechat_account.app_secret,
      redis_key: "ssobu_wx_#{wechat_account.id}"
    )
  end

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
