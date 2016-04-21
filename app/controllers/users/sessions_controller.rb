class Users::SessionsController < Devise::SessionsController

  include WechatRewarable

  detect_device only: [:new, :create]

  layout :new_login_layout

  before_filter :configure_sign_in_params, only: [:create]

  respond_to :json, :html

  # GET /resource/sign_in
  def new
    if params[:redirect] == "activity"
      render 'activity', layout: 'activity'
    else
      @using_captcha = sign_in_params[:password].blank?
      super
    end
  end

  # POST /resource/sign_in
   def create
     if sign_in_params[:mobile_auth_code].present?
       @using_captcha = true
       if MobileCaptcha.auth_code(sign_in_params[:login], sign_in_params[:mobile_auth_code])
         self.resource = User.find_or_create_guest_with_session(sign_in_params[:login], session)
         if resource.persisted?
           sign_in(resource)
           MobileCaptcha.clear_captcha(sign_in_params[:login])
           Ubonus::Invite.delay.active_by_user_id(resource.id)
           respond_to do |format|
             format.html { redirect_to after_sign_in_path_for(resource) }
             format.json { render json: { user_id: resource.id } }
           end
         else
           error_msg = resource.errors.full_messages.join('<br/>')
           respond_to do |format|
             format.html { render_or_redirect(error_msg, params[:redirect]) }
             format.json { render json: { error: error_msg }, status: 422 }
           end
         end
       else
         self.resource = resource_class.new(sign_in_params)
         error_msg = '手机验证码错误'
         respond_to do |format|
           format.html { render_or_redirect(error_msg, params[:redirect]) }
           format.json { render json: { error: error_msg }, status: 401 }
         end
       end
     else
       wechat_omniauth_data = { "devise.wechat_data" => session["devise.wechat_data"] }
       super do |user|
         Ubonus::Invite.delay.active_by_user_id(resource.id)
         user.update_with_oauth_session(wechat_omniauth_data) if wechat_omniauth_data.present?
         if request.format == 'json'
           @csrf_param = request_forgery_protection_token
           @csrf_token = form_authenticity_token
         end
       end
     end
   end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << :mobile_auth_code
  end

  def render_or_redirect(message, redirect)
    if redirect == "activity"
      flash[:error] = message
      redirect_to new_user_session_path(redirect: redirect, redirectUrl: params[:redirectUrl])
    else
      flash.now[:error] = message
      render :new
    end
  end

end
