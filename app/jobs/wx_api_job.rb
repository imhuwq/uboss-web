class WxApiJob < ActiveJob::Base

  queue_as :weixin_api

  attr_reader :job_options, :wechat_account

  def perform(job_options = {})
    @job_options = job_options
    job_type = job_options.delete(:job_type)
    method_name = "handle_#{job_type}"
    if self.respond_to? method_name, true
      send(method_name)
    else
      Rails.logger.info("WxApiJob Unknow Jobtype #{job_type}")
    end
  end

  private

  def handle_scene_qrcode
    wx_scene = job_options.fetch(:wx_scene).reload
    @wechat_account = wx_scene.properties['wechat_account']

    if true#wx_scene.properties['scene_url'].blank? || wx_scene.expired?
      if wx_scene.request_wx_qrcode
        Rails.logger.info('生成二维码图片成功')
      else
        weixin_client.send_text_custom(wx_scene.properties['weixin_openid'], '二维码生成失败，请稍后重试')
      end
    end

    if false#wx_scene.properties['qrcode_media_id'].present?
      weixin_client.send_text_custom(
        wx_scene.properties['weixin_openid'],
        "获取二维码成功，将在#{wx_scene.expire_at.strftime('%Y-%m-%d')}失效，邀请好友一起来UBOSS吧"
      )
      wx_scene.send_qrcode_image_message
    else
      if wx_scene.upload_wx_qrcode
        weixin_client.send_text_custom(
          wx_scene.properties['weixin_openid'],
          "二维码生成成功，将在#{wx_scene.expire_at.strftime('%Y-%m-%d')}失效，邀请好友一起来UBOSS吧"
        )
        wx_scene.send_qrcode_image_message
      else
        weixin_client.send_text_custom(wx_scene.properties['weixin_openid'], '二维码发送失败，请稍后重试')
      end
    end
  end

  def handle_scan_scene_qrcode
    wx_scene = job_options.fetch(:wx_scene).reload
    @wechat_account = wx_scene.properties['wechat_account']
    scan_weixin_openid = job_options[:scan_weixin_openid]

    invitor_weixin_openid = wx_scene.properties['weixin_openid']
    invitor = wx_scene.user
    invite_reward = Ubonus::WeixinInviteReward.new(
      amount: rand(5..100)/100.0,
      user: invitor,
      properties: {
        to_wx_user_id: invitor_weixin_openid,
        from_wx_user_id: scan_weixin_openid
      }
    )

    if invite_reward.save
      user_response = weixin_client.user(scan_weixin_openid)
      scan_user_name = user_response.is_ok? ? user_response.result['nickname'] : '微信用户'
      message = <<-MSG
【#{scan_user_name}】扫了您的二维码，余额增加#{invite_reward.amount}元，当前余额：#{invite_reward.user_total_income}元，满1元即可点击<a href='#{wx_scene.income_link}'>【我的收益】</a>提现
      MSG
      weixin_client.send_text_custom(wx_scene.properties['weixin_openid'], message)
    else
      Rails.logger.info("重复扫描微信关注邀请码：#{invite_reward.errors.full_messages}")
    end

  end

  def weixin_client
    @weixin_client ||= ($weixin_clients[wechat_account] || $weixin_client)
  end

end
