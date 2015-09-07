class Api::V1::SessionsController < ApiBaseController

  skip_before_action :authenticate_user_from_token!, :authenticate_user!

  def create
    login = params.fetch(:login)
    if params[:mobile_captcha].present?
      if MobileAuthCode.auth_code(login, params[:mobile_captcha])
        @user = User.find_or_create_guest(login)
        if @user.persisted?
          MobileAuthCode.clear_captcha(sign_in_params[:login])
        else
          render_error :wrong_params, model_errors(@user), 422
        end
      else
        render_error :invalid_login, '手机验证码错误', 401
      end
    elsif @user = User.find_for_authentication(login: login)
      if not @user.valid_password?(params[:password])
        render_error :invalid_login, '账号或密码错误', 401
      end
    else
      render_error :invalid_login, '账号或密码错误', 401
    end
  end

end
