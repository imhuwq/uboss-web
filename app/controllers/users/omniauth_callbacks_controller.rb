class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def wechat
    if current_user
      current_user.update_with_wechat_oauth(auth_info.extra['raw_info'])
    else
      user = User.find_or_create_by_wechat_oauth(auth_info.extra['raw_info'])
      sign_in(user)
    end
    redirect_to after_oauth_success_redirect_path
  end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  protected

  def auth_info
    request.env["omniauth.auth"]
  end

  def after_oauth_success_redirect_path
    session[:oauth_callback_redirect_path] || root_path
  end

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
