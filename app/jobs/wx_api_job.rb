class WxApiJob < ActiveJob::Base

  queue_as :default

  attr_reader :options

  def perform(options = {})
    @options = options
    job_type = options.delete(:job_type)
    method_name = "handle_#{job_type}"
    if self.respond_to? method_name, true
      send(method_name)
    else
      Rails.logger.info("WxApiJob Unknow Jobtype #{job_type}")
    end
  end

  private

  def handle_scene_qrcode
    wx_scene = options[:wx_scene].reload

    if wx_scene.properties['scene_url'].blank?
      if wx_scene.request_wx_qrcode
        wx_scene.send_success_text_message
      else
        $weixin_client.send_text_custom(properties['weixin_openid'], '二维码生成失败，请稍后重试')
      end
    end

    if wx_scene.properties['qrcode_media_id'].present?
      wx_scene.send_qrcode_image_message
    else
      if wx_scene.upload_wx_qrcode
        wx_scene.send_qrcode_image_message
      else
        $weixin_client.send_text_custom(properties['weixin_openid'], '二维码发送失败，请稍后重试')
      end
    end
  end

end
