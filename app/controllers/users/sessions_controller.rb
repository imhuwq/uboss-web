class Users::SessionsController < Devise::SessionsController

  layout :login_layout

  before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    @using_password = sign_in_params[:mobile_auth_code].blank?
    super
  end

  # POST /resource/sign_in
   def create
     if true#simple_captcha_valid?
       if sign_in_params[:mobile_auth_code].present?
         if true#MobileAuthCode.auth_code(sign_in_params[:login], sign_in_params[:mobile_auth_code])
           self.resource = User.find_or_create_guest_with_session(sign_in_params[:login], session)
           if resource.persisted?
             sign_in(resource)
             respond_with resource, location: after_sign_in_path_for(resource)
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
        super do |user|
          user.update_with_oauth_session(session)
        end
       end
     else
       self.resource = resource_class.new(sign_in_params)
       clean_up_passwords(resource)
       set_flash_message(:notice, :invalid_captcha) if is_flashing_format?
       render :new
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

  def login_layout
    if !browser.mobile? && !browser.tablet?
      'login'
    else
      'application'
    end
  end
end
