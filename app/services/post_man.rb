module PostMan extend self

  class SendFail < StandardError
    attr_reader :fail_result

    def initialize(fail_result)
      @fail_result = fail_result
    end
  end

  def send_sms(mobile, message, tpl_id = 923_651)
    return result_message('手机格式错误',     false) if not validate_mobile(mobile)
    return result_message('电话号码不能为空', false) if mobile.blank?
    return result_message('内容不能为空',     false) if message.blank?

    result = ChinaSMS.to(mobile, { code: message, company: '优巭UBOSS' }, tpl_id: tpl_id)

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
    result_message('短信发送失败', false)
  end

  private

  def result_message(message, success = true)
    { success: success, message: message }
  end

  def validate_mobile(mobile)
    mobile =~
      /\A(\s*)(?:\(?[0\+]?\d{1,3}\)?)[\s-]?(?:0|\d{1,4})[\s-]?(?:(?:13\d{9})|(?:\d{7,8}))(\s*)\Z|\A[569][0-9]{7}\Z/
  end

end
