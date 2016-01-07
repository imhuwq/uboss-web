module WxApiService extend self

  CUSTOMER_MESSAGE = <<-MSG
如需人工服务，请选择“UBOSS+”的“<a href="http://mp.weixin.qq.com/s?__biz=MzIwMTUwNzU4MA==&mid=400624022&idx=1&sn=268c41d3d21a4729628a5ee8d17f2612&scene=18#rd">联系我们</a>“。

6.4亿红包疯狂抢>><a href="http://uboss.me/ls_game">开始抢钱</a>

双十二，神秘活动即将开始！
  MSG

  SUBSCRIBE_MESSAGE = <<-MSG
UBOSS，一个边买边赚的商城！引领行业的分享新玩法，旨在重构中国商业信用体系，让好商品引爆销量。
更重要的是，商家入驻UBOSS完全免费！
如需人工服务，请选择“UBOSS+”的“<a href="http://mp.weixin.qq.com/s?__biz=MzIwMTUwNzU4MA==&mid=400624022&idx=1&sn=268c41d3d21a4729628a5ee8d17f2612&scene=18#rd">联系我们</a>“。
  MSG

  def invoke_personal_invite_sence(options = {})
    weixin_openid = options[:weixin_openid]

    if wx_scene = WxScene.with_properties(weixin_openid: weixin_openid).first
      wx_scene.request_wx_sence_and_send_message
    else
      WxScene.create(
        expire_at: Time.now + 30.days,
        properties: {
          weixin_openid: weixin_openid
        }
      )
    end
  end

  def handle_subscribe_scan_keyword(options)
    keyword = options.delete(:keyword)
    keyword.slice!('qrscene_')
    if wx_scene = WxScene.find_by(scene_id: keyword)
      wx_scene.invoke_scan_success(options)
    end
  end

end
