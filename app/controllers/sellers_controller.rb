class SellersController < AdminController
  layout 'login'
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
      if user.save and user.user_roles << @user_role and user.save
        MobileAuthCode.find_by(code: allow_params[:mobile_auth_code]).try(:destroy)
        flash[:success] = "绑定注册成功"
        sign_in user
        redirect_to '/admin'
        return
      else
        flash[:error] = user.errors.full_messages.join('<br/>')
        redirect_to action: :new
      end
    end
  end

  def update
    valid_create_params
    if current_user.is_seller? and !current_user.authenticated?
      if @errors.present?
        flash[:error] = @errors.join("\n")
      else
        current_user.update(agent_id: allow_params[:agent_id])
        flash[:success] = "绑定成功！"
        redirect_to admin_root_path
        return
      end
    else
      flash[:error] = "您已经是认证商家，不能更换绑定."
    end
    redirect_to action: :new, agent_code: User.find_by(id: allow_params[:agent_id]).try(:agent_code)
  end
  private
  def allow_params
    params.require(:seller).permit(:mobile, :mobile_auth_code, :password, :password_confirmation, :agent_id)
  end
  def valid_create_params
    @errors = []
    hash = {
      '验证码错误或已过期。': MobileAuthCode.auth_code(allow_params[:mobile], allow_params[:mobile_auth_code]),
      # '创客域名错误。': User.find_by(id: allow_params[:agent_id]),
      '还不允许商家注册,请联系管理员.': @user_role = UserRole.find_by(name: 'seller')
    }
    hash.each do |k, v|
      @errors << k unless v.present?
    end
  end
end
