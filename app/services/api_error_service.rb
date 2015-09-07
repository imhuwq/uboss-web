class ApiErrorService
  attr_accessor :errid, :msg, :status_code

  class UnknwonErrorId < RuntimeError; end

  DICT = {
    unauthorized:               401, # 没通过用户认证
    forbidden:                  403, # 权限不够
    not_found:                  404, # 找不到对应资源
    unprocessable:              422, # 请求参数非法
    too_many_requests:          429, # 请求频率超出限制
    wrong_username_or_password: 401001, # 用户名密码错误
    wrong_params:               422001, # 参数错误，或缺少参数
    validation_failed:          422002, # 模型验证错误
    captcha_invalid:            422003, # 验证码不匹配或者过期
    already_binding_mobile:     422004, # 该手机号已绑定
    mobile_captcha_fail:        424001, # 短信发送失败
  }

  def self.lookup errid
    status = DICT[errid.to_sym] || raise(UnknwonErrorId, errid)

    new.tap do |instance|
      instance.errid = status
      instance.msg = I18n.t("api_errors.#{errid}")
      instance.status_code = (status < 1000) ? status : status/1000
    end
  end
end
