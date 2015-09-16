class ApplicationController < ActionController::Base

  include SimpleCaptcha::ControllerHelpers
  include DetectDevise

  helper_method :desktop_request?

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  # default: order by created_at, limit 20, page 1
  # order_column to change order column and page columns
  # page_size to change limit size
  def append_default_filter scope, opts = {}
    scope.recent(opts[:order_column], opts[:order_type])
    .paginate_by_timestamp(before_ts, after_ts, opts[:order_column])
    .page(page_param).per(opts[:page_size] || page_size)
  end

  def before_ts
    return Time.zone.parse(before_ts_param) if before_ts_param
    nil
  end

  def after_ts
    return Time.zone.parse(after_ts_param) if after_ts_param
    nil
  end

  def before_ts_param
    params['before_published_at']
  end

  def after_ts_param
    params["after_published_at"]
  end

  def page_size
    (params['page_size'] && params['page_size'].to_i > 0) ? params['page_size'].to_i : 20
  end

  def page_param
    (params['page'] && params['page'].to_i > 0) ? params['page'].to_i : 1
  end

  def model_errors(model)
    model.errors.full_messages
  end

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
      seller_sharing_node = sharing_node.lastest_seller_sharing_node(sharing_node.product.user)
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
      request.env['omniauth.origin'] || stored_location_for(resource) || (current_user.admin? ? admin_root_path : root_path)
    end
  end
  helper_method :after_sign_in_path_for
end
