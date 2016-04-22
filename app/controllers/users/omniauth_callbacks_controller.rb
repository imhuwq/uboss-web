class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  include WechatRewarable

  def wechat
    if current_user
      current_user.update_with_wechat_oauth(auth_info.extra['raw_info'])
    elsif user = User.find_or_update_by_wechat_oauth(auth_info.extra['raw_info'])
      sign_in(user)
    else
      session["devise.wechat_data"] = auth_info
    end
    if current_user.blank? && path_force_login?
      if after_oauth_success_redirect_path.match(/promotion_activities/).present?
        redirect_to new_user_session_path(redirect: 'activity')
      else
        redirect_to new_user_session_path
      end
    else
      current_user && Ubonus::Invite.delay.active_by_user_id(current_user.id)
      redirect_to after_oauth_success_redirect_path.gsub(/redirect=draw/, 'redirect=drawing')
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

  def path_force_login?
    after_oauth_success_redirect_path.match(/orders|pay_bill|bill_complete|calling_services/).blank?
  end

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
