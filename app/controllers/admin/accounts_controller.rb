class Admin::AccountsController < AdminController

  def edit
    if current_user.is_agent?
      current_user.find_or_create_agent_code
    end
  end

  def update
    user_params = params.require(:user).permit(:mobile, :email, :nickname, :store_name, :agent_code, :avatar)

    if current_user.update(user_params)
      redirect_to admin_root_path, notice: '修改成功'
    else
      render :edit
    end
  end

  def update_password
    user_params = params.require(:user).permit(:password, :password_confirmation, :current_password)

    if current_user.update_with_password(user_params)
      sign_in current_user, :bypass => true
      redirect_to admin_root_path, notice: '修改密码成功'
    else
      render :password
    end
  end

  def bind_agent
    agent_code = params[:user][:code]
    if current_user.check_bind_condition
      if params['binding_submit'].present?
        if current_user.bind_agent(agent_code)
          AgentInviteSellerHistroy.find_by(mobile: current_user.login).try(:update, status: 1)
          flash[:notice] = '绑定成功<br/>'
          redirect_to after_binding_agent_path
        else
          render :binding_agent
          return
        end
      else
        redirect_to after_binding_agent_path
      end
    else
      flash[:error] = model_errors(current_user).join('<br/>')
      redirect_to action: :edit
    end

  end

  private

  def after_binding_agent_path
    if current_user.need_reset_password?
      flash[:notice] ||= ''
      flash[:notice] += '请设定密码以继续'
      flash[:new_password_enabled] = true
      set_password_path
    else
      admin_root_path
    end
  end
end
