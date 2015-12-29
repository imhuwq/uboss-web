class MobileCaptchasController < ApplicationController

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
    if params[:captcha_type]
      result = MobileCaptcha.send_captcha_with_mobile(params[:mobile], params[:captcha_type], current_user.id)
    else
      result = MobileCaptcha.send_captcha_with_mobile(params[:mobile])
    end

    status = result[:success] ? :ok : :bad_request

    render json: {
      message: model_errors(result[:mobile_auth_code])
    }, status: status
  end

end
