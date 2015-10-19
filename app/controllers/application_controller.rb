class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  include SimpleCaptcha::ControllerHelpers
  include DetectDevise
  include FilterLogic

  helper_method :desktop_request?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def model_errors(model)
    model.errors.full_messages
  end
  helper_method :model_errors

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
    if desktop_request?
      'login'
    else
      'application'
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:login, :captcha, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :password, :remember_me, :mobile_auth_code, :captcha, :captcha_key) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:login, :password, :password_confirmation, :current_password) }
  end

  def after_sign_in_path_for(resource, opts = {need_new_passowrd: true})
    if desktop_request? && !current_user.admin?
      merchant_confirm_account_path
    elsif current_user.need_reset_password? && opts[:need_new_passowrd]
      flash[:new_password_enabled] = true
      set_password_path
    else
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

  def qr_sharing?
    params['shared'] == 'true'
  end
  helper_method :qr_sharing?
end
