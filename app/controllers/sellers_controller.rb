class SellersController < AdminController
  # layout 'application'

  detect_device only: [:new]

  layout :detect_layout, only: [:new]

  def new
    @agent = User.find_by(agent_code: params[:agent_code]) if params[:agent_code].present?
  end

  def create
    valid_create_params
    if @errors.present?
      flash[:error] = @errors.join("\n")
      redirect_to action: :new
      return
    else
      user = User.new(allow_params)
      user.login = allow_params[:mobile]
      user.admin = true
      if user.save and user.user_roles << @user_role
        MobileCaptcha.find_by(code: allow_params[:mobile_auth_code]).try(:destroy)
        user.bind_agent(user.agent.try(:agent_code))
        flash[:success] = "成功注册并绑定创客#{user.agent.identify}."
        sign_in user
        redirect_to root_path
        return
      else
        flash[:error] = user.errors.full_messages.join('<br/>')
        redirect_to action: :new
      end
    end
  end

  def update
    valid_create_params
    if current_user.can_rebind_agent?
      if @errors.present?
        flash[:error] = @errors.join("\n")
      elsif user = User.find_by(id: allow_params[:agent_id])
        #current_user.update(agent_id: allow_params[:agent_id])
        current_user.bind_agent(user.try(:agent_code))
        flash[:success] = "成功绑定创客#{current_user.agent.identify}！"
        redirect_to root_path
        return
      else
        flash[:error] = "找不到创客"
      end
    else
      flash[:error] = model_errors(current_user).join('<br/>')
    end
    redirect_to action: :new, agent_code: User.find_by(id: allow_params[:agent_id]).try(:agent_code)
  end

  private

  def allow_params
    params.require(:seller).permit(:mobile, :mobile_auth_code, :password, :password_confirmation, :agent_id)
  end

  def valid_create_params
    @errors = []
    mobile = current_user ? current_user.login : allow_params[:mobile]
    hash = {
      '验证码错误或已过期。': MobileCaptcha.auth_code(mobile, allow_params[:mobile_auth_code]),
      # '创客域名错误。': User.find_by(id: allow_params[:agent_id]),
      '还不允许商家注册,请联系管理员.': @user_role = UserRole.find_by(name: 'seller')
    }
    hash.each do |k, v|
      @errors << k unless v.present?
    end
  end

   def detect_layout
    if not desktop_request?
      'mobile'
    else
      'login'
    end
  end

end
