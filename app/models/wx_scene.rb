require 'emoji_cleaner'

class WxScene < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :expire_at

  after_create :set_scene_id
  after_commit :request_wx_sence_and_send_message, on: :create

  scope :with_properties, -> (conditions) { where("properties @> ?", conditions.to_json) }

  def expired?
    Time.now > expire_at
  end

  def income_link
    query = {scene_identify: CryptService.encrypt(self.id)}.to_query
    "#{Rails.application.secrets.host_url}/account?#{query}"
  end

  def request_wx_sence_and_send_message
    WxApiJob.perform_later(job_type: 'scene_qrcode', wx_scene: self)
  end

  def invoke_scan_success(options)
    WxApiJob.perform_later(
      job_type: 'scan_scene_qrcode',
      wx_scene: self,
      wechat_account: options[:wechat_account],
      scan_weixin_openid: options[:weixin_openid]
    )
  end

  def update_properties(ext_properties)
    self.properties = properties.merge(ext_properties)
    self.save
  end

  def request_wx_qrcode
    remain_times = expired? ? 30.days : expire_at - Time.now
    response = weixin_client.create_qr_scene(scene_id, remain_times)
    if response.is_ok?
      self.expire_at = Time.now + remain_times
      update_properties(
        scene_ticket: response.result['ticket'],
        scene_url: response.result['url'],
        qrcode_media_id: nil
      )
      true
    else
      update_properties(qrcode_media_id: nil) if properties['qrcode_media_id'].present?
      Rails.logger.info("获取二维码失败: #{response}")
      false
    end
  end

  def upload_wx_qrcode
    return false if properties['scene_ticket'].blank?

    user_response = weixin_client.user(properties['weixin_openid'])
    nickname = '微信用户'
    nickname = user_response.result['nickname'] if user_response.is_ok?

    request_image_query_param = {
      qrcode_content: properties['scene_url'],
      username: EmojiCleaner.clear(nickname),
      num: Ubonus::WeixinInviteReward.with_properties(to_wx_user_id: properties['weixin_openid']).count,
      exp_time: expire_at.strftime('%Y-%m-%d'),
      mode: 0
    }.to_param
    image_url = "http://imager.ulaiber.com/req/0?#{request_image_query_param}"

    begin
      media_response = weixin_client.upload_media(image_url, 'image')
      if media_response.is_ok?
        update_properties(
          qrcode_media_id: media_response.result['media_id']
        )
        true
      else
        Rails.logger.info("上传邀请二维码失败, response: #{media_response}")
        false
      end
    rescue => e
      Rails.logger.info("上传邀请二维码失败, url: #{image_url} error: #{e.message}")
      Rails.logger.error e.backtrace.inspect
      false
    end
  end

  def send_qrcode_image_message
    weixin_client.send_image_custom(properties['weixin_openid'], properties['qrcode_media_id'])
  end

  private

  def weixin_client
    @weixin_client ||= ($weixin_clients[properties['wechat_account']] || $weixin_client)
  end

  def set_scene_id
    update_columns(scene_id: id)
  end

end
