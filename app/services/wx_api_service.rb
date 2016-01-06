module WxApiService extend self

  def invoke_personal_invite_sence(options = {})
    weixin_openid = options[:weixin_openid]

    if wx_scene = WxScene.with_properties(weixin_openid: weixin_openid).first
      wx_scene.request_wx_sence_and_send_message
    else
      WxScene.create(
        expire_at: Time.now + 8.days,
        properties: {
          weixin_openid: weixin_openid
        }
      )
    end
  end

end
