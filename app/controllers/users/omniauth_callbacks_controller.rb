class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def wechat
    if current_user
      current_user.update_with_wechat_oauth(auth_info.extra['raw_info'])
    elsif user = User.find_or_update_by_wechat_oauth(auth_info.extra['raw_info'])
      sign_in(user)
    else
      session["devise.wechat_data"] = auth_info
    end
    if current_user.blank? && after_oauth_success_redirect_path.match(/orders/).blank?
      redirect_to new_user_session_path
    else
      redirect_to after_oauth_success_redirect_path
    end
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
