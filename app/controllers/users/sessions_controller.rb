class Users::SessionsController < Devise::SessionsController
  layout :login_layout
  # before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   if simple_captcha_valid?
  #     super
  #   else
  #     self.resource = resource_class.new(sign_in_params)
  #     clean_up_passwords(resource)
  #     set_flash_message(:notice, :invalid_captcha) if is_flashing_format?
  #     render :new
  #   end
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
  private
  def login_layout
    if !browser.mobile? && !browser.tablet?
      'login'
    else
      'application'
    end
  end
end
