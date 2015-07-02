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
  'ssobu_wxtk'
)
