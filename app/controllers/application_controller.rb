class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  layout 'mobile'

  include SimpleCaptcha::ControllerHelpers
  include DetectDevise
  include FilterLogic

  helper_method :desktop_request?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def authentication_token
    request.headers["User-Token"] || params[:accesstoken]
  end

  def authentication_login
    request.headers["User-Login"] || params[:login]
  end

  def login_app(force = false)
    return false if current_user.present?

    user = authentication_login && User.find_for_database_authentication(login_identifier: authentication_login)
    if user && Devise.secure_compare(user.authentication_token, authentication_token)
      session[:app_user] = true
      env['devise.skip_trackable'] = true
      sign_in user
    elsif force
      flash[:error] = '自动登入失败'
      redirect_to new_user_session_path
    end
  end

  def model_errors(model)
    model.errors.full_messages
  end
  helper_method :model_errors

  def authenticate_user!
    store_location_for(:user, request.referer) if request.post? && !request.xhr?
    if Rails.env.development? && params[:mode] == 'admin'
      login_with_admin_model
    elsif browser.wechat?
      authenticate_weixin_user!
    elsif browser.uboss?
      login_app(true)
    else
      super
    end
  end

  def authenticate_weixin_user!(redirect = nil)
    return false unless browser.wechat?
    return false unless current_user.blank? || current_user.weixin_openid.blank?

    path = request.get? ? request.fullpath : request.referer
    if redirect.present?
      path += path.match(/\?/) ? "&redirect=#{redirect}" : "?redirect=#{redirect}"
    end

    session[:oauth_callback_redirect_path] = path
    redirect_to user_omniauth_authorize_path(:wechat)
  end

  # for actions need weixin openid but not uboss user
  # skip wechat user confirm page
  def authenticate_weixin_user_token!
    # Force request wehat token
    # return false if !browser.wechat?
    if params[:mode] == 'test' && Rails.env.development?
      session["devise.wechat_data"] = {'extra' => { 'raw_info' => { 'openid' => 'fake-openid' } }}
    end
    return false if current_user && current_user.weixin_openid.present?
    return false if session["devise.wechat_data"].present?

    session[:oauth_callback_redirect_path] = request.fullpath
    redirect_to user_omniauth_authorize_path(:wechat, scope: 'snsapi_base')
  end

  def login_with_admin_model
    user = User.first
    user.update(weixin_openid: 'fake-admin') if user.weixin_openid.blank?
    sign_in(User.first)
  end

  def get_product_or_store_sharing_code(product)
    get_seller_sharing_code(product.user_id) || get_product_sharing_code(product.id)
  end

  def get_product_sharing_code(product_id)
    cookies["sc_#{product_id}"]
  end

  def get_seller_sharing_code(seller_id)
    cookies["ssc_#{seller_id}"]
  end

  def set_product_sharing_code(product_id, code)
    cookies["sc_#{product_id}"] = { value: code, expires: 24.hour.from_now }
  end

  def set_seller_sharing_code(seller_id, code)
    cookies["ssc_#{seller_id}"] = { value: code, expires: 24.hour.from_now }
  end

  def set_sharing_code(sharing_node)
    if sharing_node.product_id.present?
      set_product_sharing_code(sharing_node.product_id, sharing_node.code)
      seller_sharing_node = sharing_node.lastest_seller_sharing_node
      set_seller_sharing_code(sharing_node.product.user_id, seller_sharing_node.code)
    else
      set_seller_sharing_code(sharing_node.seller_id, sharing_node.code)
    end
  end

  def login_layout
    desktop_request? ? 'login' : 'application'
  end

  def new_login_layout
    desktop_request? ? 'login' : 'mobile'
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u|
      u.permit(:login, :email, :login_identifier, :captcha, :password, :password_confirmation, :remember_me)
    }
    devise_parameter_sanitizer.for(:sign_in) { |u|
      u.permit(:login, :email, :login_identifier, :password, :remember_me, :mobile_auth_code, :captcha, :captcha_key)
    }
    devise_parameter_sanitizer.for(:account_update) { |u|
      u.permit(:login, :email, :login_identifier, :password, :password_confirmation, :current_password)
    }
  end

  def after_sign_in_path_for(resource, opts = {need_new_passowrd: true})
    if ['discourse', 'activity'].include? params[:redirect]
      params[:redirectUrl]
    elsif current_user.need_reset_password? && opts[:need_new_passowrd] && session[:oauth_callback_redirect_path].try(:match, /promotion_activities/).blank?
      flash[:new_password_enabled] = true
      set_password_path
    else
      session[:oauth_callback_redirect_path] ||
        request.env['omniauth.origin'] ||
        stored_location_for(resource) ||
        logined_redirect_path
    end
  end
  helper_method :after_sign_in_path_for

  def current_cart
    @current_cart ||= find_cart
  end
  helper_method :current_cart

  def find_cart
    cart = current_user.cart
    cart ||= Cart.create(user: current_user)
  end

  def logined_redirect_path
    if desktop_request?
      current_user.admin? ? admin_root_path : root_path
    else
      root_path
    end
  end

  def authenticate_user_if_browser_wechat
    if browser.wechat? && session['devise.wechat_data'].blank?
      authenticate_user!
    end
  end

  def qr_sharing?
    params['shared'] == 'true'
  end
  helper_method :qr_sharing?

  def activity_sign_in_and_redirect_path(type, promotion_activity)
    if type == "share"
      redirect_url = share_draw_promotion_activity_path(promotion_activity)
    else
      redirect_url = live_draw_promotion_activity_path(promotion_activity)
    end

    return new_user_session_path(redirect: 'activity', redirectUrl: redirect_url)
  end
  helper_method :activity_sign_in_and_redirect_path

  def get_weixin_openid_form_session
    session["devise.wechat_data"] && session["devise.wechat_data"]["extra"]["raw_info"]["openid"]
  end

  def store_account
    current_user && current_user.store_accounts.active.find_by(user_id: session[:store_account_id]).try(:user)
  end

  def realtime_user_id
    (store_account && store_account.id) ||
    (current_user && current_user.id) || 1
  end

  def realtime_server_url
    Rails.application.secrets.realtime_server_url
  end

end
