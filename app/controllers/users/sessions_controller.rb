class Users::SessionsController < Devise::SessionsController

  detect_device only: [:new, :create]

  layout :login_layout

  before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    @using_captcha = sign_in_params[:password].blank?
    super
  end

  # POST /resource/sign_in
   def create
     if sign_in_params[:mobile_auth_code].present?
       if MobileCaptcha.auth_code(sign_in_params[:login], sign_in_params[:mobile_auth_code])
         self.resource = User.find_or_create_guest_with_session(sign_in_params[:login], session)
         if resource.persisted?
           sign_in(resource)
           MobileCaptcha.clear_captcha(sign_in_params[:login])
           Ubonus::Invite.delay.active_by_user_id(resource.id)
           redirect_to after_sign_in_path_for(resource)
         else
           flash.now[:error] = resource.errors.full_messages.join('<br/>')
           render :new
         end
       else
         self.resource = resource_class.new(sign_in_params)
         flash.now[:error] = '手机验证码错误'
         render :new
       end
     else
       wechat_omniauth_data = { "devise.wechat_data" => session["devise.wechat_data"] }
       super do |user|
         Ubonus::Invite.delay.active_by_user_id(resource.id)
         user.update_with_oauth_session(wechat_omniauth_data) if wechat_omniauth_data.present?
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

end
