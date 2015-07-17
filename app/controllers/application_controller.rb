class ApplicationController < ActionController::Base

  include SimpleCaptcha::ControllerHelpers
  include DetectDevise

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def authenticate_user!
    if Rails.env.development? && params[:mode] == 'admin'
      login_with_admin_model
    elsif browser.wechat?
      authenticate_weixin_user!
    else
      super
    end
  end

  def authenticate_weixin_user!
    return false unless browser.wechat?
    return false unless current_user.blank? || current_user.weixin_openid.blank?

    session[:oauth_callback_redirect_path] = request.fullpath
    redirect_to user_omniauth_authorize_path(:wechat)
  end

  def login_with_admin_model
    user = User.first
    user.update(weixin_openid: 'fake-admin') if user.weixin_openid.blank?
    sign_in(User.first)
  end

  def param_page
    params[:page] || 0
  end

  def get_product_sharing_code(product_id)
    cookies["sc_#{product_id}"]
  end

  def set_product_sharing_code(product_id, code)
    cookies["sc_#{product_id}"] = { value: code, expires: 24.hour.from_now }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:login, :captcha, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password, :remember_me, :captcha, :captcha_key) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:login, :password, :password_confirmation, :current_password) }
  end
end
