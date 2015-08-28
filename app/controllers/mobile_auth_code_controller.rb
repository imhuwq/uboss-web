class MobileAuthCodeController < ApplicationController

  def create
    invoke_captcha_sending
  end

  def send_with_captcha
    if simple_captcha_valid?
      invoke_captcha_sending
    else
      render json: { message: '验证码错误' }, status: :failure
    end
  end

  private

  def invoke_captcha_sending
    result = MobileAuthCode.send_captcha_with_mobile(params[:mobile])
    status = result[:success] ? :ok : :bad_request

    render json: {
      message: model_errors(result[:mobile_auth_code])
    }, status: status
  end

end
