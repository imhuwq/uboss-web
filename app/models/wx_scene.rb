class WxScene < ActiveRecord::Base

  after_create :set_scene_id
  after_commit :request_wx_sence_and_send_message, on: :create

  scope :with_properties, -> (conditions) { where("properties @> ?", conditions.to_json) }

  def request_wx_sence_and_send_message
    WxApiJob.perform_later(job_type: 'scene_qrcode', wx_scene: self)
  end

  def invoke_scan_success(options)
    WxApiJob.new.perform(
      job_type: 'scan_scene_qrcode',
      wx_scene: self,
      scan_weixin_openid: options[:weixin_openid]
    )
  end

  def update_properties(ext_properties)
    update(properties: properties.merge(ext_properties))
  end

  def request_wx_qrcode
    remain_times = expire_at.present? ? expire_at - Time.now : 30.days
    response = $weixin_client.create_qr_scene(scene_id, remain_times)
    if response.is_ok?
      update_properties(
        scene_ticket: response.result['ticket'],
        scene_url: response.result['url']
      )
      true
    else
      $weixin_client.send_text_custom(properties['weixin_openid'], '二维码生成失败，请稍后重试')
      Rails.logger.info("获取二维码失败: #{response.result}")
      false
    end
  end

  def upload_wx_qrcode
    qrcode_url = $weixin_client.qr_code_url(properties['scene_ticket'])
    media_response = $weixin_client.upload_media(qrcode_url, 'image')
    if media_response.is_ok?
      update_properties(
        qrcode_media_id: media_response.result['media_id']
      )
      true
    else
      Rails.logger.info("上传邀请二维码失败 #{job_type}")
      false
    end
  end

  def send_qrcode_image_message
    $weixin_client.send_image_custom(properties['weixin_openid'], properties['qrcode_media_id'])
  end

  def send_success_text_message
    $weixin_client.send_text_custom(properties['weixin_openid'], '二维码生成成功')
  end
  private

  def set_scene_id
    update_columns(scene_id: id)
  end

end
