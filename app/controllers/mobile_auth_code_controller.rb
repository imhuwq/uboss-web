class MobileAuthCodeController < ApplicationController

  def create
    result = MobileAuthCode.send_captcha_with_mobile(params[:mobile])

    render json: { message: model_errors(result[:mobile_auth_code]) }, status: result[:success] ? :failure : :ok
  end

end
