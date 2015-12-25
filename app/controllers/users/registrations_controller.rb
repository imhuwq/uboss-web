class Users::RegistrationsController < Devise::RegistrationsController

  #before_filter :configure_sign_up_params, only: [:create]
  #before_filter :configure_account_update_params, only: [:update]

  layout :new_login_layout

  before_action :verfiy_message, only: [:new, :create], if: -> { params[:regist_type] == 'email' }

  # GET /resource/sign_up
  def new
    if params[:regist_type] == 'email'
      render :new_with_email
    else
      super
    end
  end

  # POST /resource
  def create
    if params[:regist_type] == 'email'
      self.resource = User.new(email: @email, password: params[:password], need_set_login: true)
      if resource.save
        sign_in(resource)
        redirect_to after_sign_up_path_for(resource)
      else
        flash[:error] = model_errors(resource).join("<br/>") if resource.errors.any?
        render :new_with_email
      end
    else
      super
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def verfiy_message
    @email, time = CryptService.verify_message(params[:confirmation_token])
    if @email.blank?
      flash[:error] = '非法的注册链接'
      redirect_to new_confirmation_path(:user, type: 'regist')
    elsif time < Time.now
      flash[:error] = '该邮件确认链接已过期'
      redirect_to new_confirmation_path(:user, type: 'regist')
    elsif User.where(email: @email).exists?
      flash[:error] = '该邮箱已注册账户'
      redirect_to new_session_path(:user)
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
