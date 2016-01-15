namespace = "ssobu:weixin_authorize"

# 每次重启时，会把当前的命令空间所有的access_token 清除掉。
exist_keys = $redis.keys("#{namespace}:*")
exist_keys.each { |key| $redis.del(key) }

# Give a special namespace as prefix for Redis key, when your have more than one project used weixin_authorize, this config will make them work fine.
wx_token_redis = Redis::Namespace.new("#{namespace}", :redis => $redis)

WeixinAuthorize.configure do |config|
  config.redis = wx_token_redis
end

$weixin_client ||= WeixinAuthorize::Client.new(
  Rails.application.secrets.weixin["app_id"],
  Rails.application.secrets.weixin["app_secret"],
  redis_key: 'ssobu_wxtk'
)

$weixin_frank_client ||= WeixinAuthorize::Client.new(
  Rails.application.secrets.weixin_frank["app_id"],
  Rails.application.secrets.weixin_frank["app_secret"],
  redis_key: 'ssobu_frank_wxtk'
)

$weixin_clients = {
  'gh_86991e4ebd98' => $weixin_client,
  'gh_7eb3e2137f71' => $weixin_frank_client
}

if false

  medias = if Rails.env.production?
             {
               maker_tutorial: '9EFRB63AS9XXBIcYwxqvKrFP4t16J2-XsP7WeSYUFeM',
               seller_tutorial: 'mInCvKRGKYG7BQ3NwYoGXEEtnzU2ZBiI9nyXKpZTJF8',
               contact_tutorial: 'q3Txbg6FYXdnKY7a5cVBzOi9f4-IgzjnKAnKxcoeU1w',
               sign_in_url: 'http://stage.uboss.me/sign_in',
               income_url: 'http://stage.uboss.me/account#showincome'
             }
           else
             {
               maker_tutorial: '64kPaTt2HyTMsJthw6vPbyAlxhhNbTonWrpLPAk3t_U',
               seller_tutorial: '64kPaTt2HyTMsJthw6vPbyAlxhhNbTonWrpLPAk3t_U',
               contact_tutorial: '64kPaTt2HyTMsJthw6vPbyAlxhhNbTonWrpLPAk3t_U',
               sign_in_url: 'http://stage.uboss.me/sign_in',
               income_url: 'http://stage.uboss.me/account#showincome'
             }
           end
  $weixin_client.create_menu(
    button: [
      {
        name: '专属二维码',
        type: 'click',
        key: 'personal_invite_qrcode'
      }, {
        name: 'UBOSS+',
        sub_button: [
          {
            name: '创客教程',
            type: 'media_id',
            media_id: medias[:maker_tutorial]
          }, {
            name: '商家教程',
            type: 'media_id',
            media_id: medias[:seller_tutorial]
          }, {
            name: '免费入驻',
            type: 'view',
            media_id: medias[:sign_in_url]
          }, {
            name: '联系我们',
            type: 'media_id',
            media_id: medias[:contact_tutorial]
          }
        ]
      }, {
        name: '我的收益',
        type: 'view',
        url: medias[:income_url]
      }
    ]
  )
end
