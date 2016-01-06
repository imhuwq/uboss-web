class Api::V1::SessionsController < ApiBaseController

  skip_before_action :authenticate_user_from_token!, :authenticate_user!

  def create
    login = params.fetch(:login)

    if params[:mobile_captcha].present?
      if MobileCaptcha.auth_code(login, params[:mobile_captcha])
        @user = User.find_or_create_guest(login)
        if @user.persisted?
          MobileCaptcha.clear_captcha(login)
        else
          render_error :wrong_username_or_password, model_errors(@user)
        end
      else
        render_error :captcha_invalid, '手机验证码错误'
      end
    elsif @user = User.find_for_authentication(login: login)
      if not @user.valid_password?(params[:password])
        render_error :wrong_username_or_password, '账号或密码错误'
      end
    else
      render_error :wrong_username_or_password, '账号或密码错误'
    end
  end

end
