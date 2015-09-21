class Api::V1::MobileCaptchasController < ApiBaseController

  skip_before_action :authenticate_user_from_token!, :authenticate_user!

  def create
    result = MobileAuthCode.send_captcha_with_mobile(params.fetch(:mobile))

    if result[:success]
      head(200)
    else
      render_error :mobile_captcha_fail, model_errors(result[:mobile_auth_code])
    end
  end

end
