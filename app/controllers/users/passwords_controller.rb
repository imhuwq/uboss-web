class Users::PasswordsController < Devise::PasswordsController

  layout :new_login_layout

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  def create
    super do |user|
      flash.now[:error] = model_errors(user).join('<br/>') if user.errors.any?
      @sending_mail = true
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  def update
    if params[:patch_type] == 'mobile'
      @sending_captcha = true
      user_params = params.require(:user).permit(:login, :password, :password_confirmation, :code)
      self.resource = User.find_by(login: user_params.delete(:login))
      if resource.blank?
        flash.now[:error] = '验证失败，请确认您的手机账户'
        self.resource = User.new
        return render :new
      end
      auth_code = user_params.delete(:code)
      resource.code = auth_code
      MobileCaptcha.verify(resource.login, auth_code).if_success {
        if resource.update(user_params.merge(need_reset_password: false))
          MobileCaptcha.where(mobile: resource.login).delete_all
          sign_in resource
          redirect_to after_sign_in_path_for(resource), notice: '修改密码成功'
        else
          flash.now[:error] = model_errors(resource).join('<br/>') if resource.errors.any?
          render :new
        end
      }.if_failure {
        flash.now[:error] = '手机验证码错误'
        render :new
      }
    else
      super do |user|
        flash.now[:error] = model_errors(user).join('<br/>') if user.errors.any?
      end
    end
  end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
