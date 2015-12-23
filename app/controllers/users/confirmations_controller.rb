class Users::ConfirmationsController < Devise::ConfirmationsController

  layout :new_login_layout

  # GET /resource/confirmation/new
   def new
     super
   end

  # POST /resource/confirmation
  def create
    if params[:type] == 'regist'
      email = params.require(:user).fetch(:email)
      UserMailer.delay.confirmation_email_instructions(email)
      flash[:notice] = '邮件确认注册链接已发送'
      redirect_to new_session_path(:user)
    else
      super do |user|
        flash[:error] = model_errors(user).join('<br/>') if user.errors.any?
      end
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
