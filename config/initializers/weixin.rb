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

if false
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
            media_id: '64kPaTt2HyTMsJthw6vPbyAlxhhNbTonWrpLPAk3t_U'
          }, {
            name: '商家教程',
            type: 'media_id',
            media_id: '64kPaTt2HyTMsJthw6vPbyAlxhhNbTonWrpLPAk3t_U'
          }, {
            name: '免费入驻',
            type: 'media_id',
            media_id: '64kPaTt2HyTMsJthw6vPbyAlxhhNbTonWrpLPAk3t_U'
          }, {
            name: '联系我们',
            type: 'click',
            key: 'contact_us'
          }
        ]
      }, {
        name: '我的收益',
        type: 'view',
        url: 'http://stage.uboss.me/account#showincome'
      }
    ]
  )
end
