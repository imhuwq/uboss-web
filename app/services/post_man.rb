module PostMan extend self

  TPL_WITH_COMPLAY = %w(1 2 3 4 5 6 7 8 9).freeze

  class SendFail < StandardError
    attr_reader :fail_result

    def initialize(fail_result)
      @fail_result = fail_result
    end
  end

  def send_sms(mobile, message_params, tpl_id = 923_651)
    return result_message('手机格式错误',     false) if not validate_mobile(mobile)
    return result_message('电话号码不能为空', false) if mobile.blank?
    return result_message('内容不能为空',     false) if message_params.blank?
    message_params.merge!(company: '优巭UBOSS') if TPL_WITH_COMPLAY.include?(tpl_id.to_s)

    result = if disable_send?(mobile)
               { 'code' => 0 }
             else
               ChinaSMS.to(mobile, message_params, tpl_id: tpl_id)
             end

    if result['code'] == 0
      result_message('发送成功')
    else
      raise SendFail.new(result), result['msg']
    end

  rescue SendFail => e
    raise e if Rails.env.development?
    Airbrake.notify_or_ignore(e,
                              parameters: e.fail_result.merge(mobile: mobile),
                              cgi_data: ENV.to_hash)
    result_message('短信发送失败', false)

  rescue StandardError => e
    raise e if Rails.env.development?
    Airbrake.notify_or_ignore(e,
                              parameters: {mobile: mobile},
                              cgi_data: ENV.to_hash)
    result_message('短信服务失败', false)
  end

  private

  def result_message(message, success = true)
    { success: success, message: message }
  end

  def validate_mobile(mobile)
    mobile =~
      /\A(\s*)(?:\(?[0\+]?\d{1,3}\)?)[\s-]?(?:0|\d{1,4})[\s-]?(?:(?:13\d{9})|(?:\d{7,8}))(\s*)\Z|\A[569][0-9]{7}\Z/
  end

  def disable_send?(mobile)
    return true if %w(13800000000).include?(mobile.to_s)
    return true if mobile.to_s[0..2] == '198'
    ENV['SMS_ENV'] == 'test' || Rails.env.test?
  end

end
