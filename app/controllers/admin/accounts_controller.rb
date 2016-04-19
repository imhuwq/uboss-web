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

  def switching_account
    if !current_user.has_store_account?
      flash[:error] = '你没有子账号'
      redirect_to :back
    else
      @store_accounts = current_user.store_accounts.active.includes(user: :service_store)
    end
  end

  def switch_account
    if params[:sid] == 'sign_out'
      current_account = set_current_account(nil)
      if current_account.blank?
        flash[:notice] = '退出成功'
      else
        flash[:error] = '退出失败'
      end
    else
      current_account = set_current_account(params[:sid])
      if params[:sid].present? && current_account.present?
        flash[:notice] = '切换成功'
      else
        flash[:error] = '切换失败'
      end
    end
    redirect_to admin_root_path
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
    if current_user.can_rebind_agent?
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

  def bind_email
    user_params = params.require(:user).permit(:email, :current_password)
    if current_user.update_with_password(user_params)
      current_user.send_confirmation_instructions
      flash[:notice] = '请查看您的邮箱，几分钟后，您将收到确认邮箱地址的电子邮件。'
      redirect_to edit_admin_account_path
    else
      flash.now[:error] = model_errors(current_user).join("<br/>")
      render :binding_email
    end
  end

  def bind_mobile
    user_params = params.require(:user).permit(:login, :code, :current_password)
    mobile = user_params[:login]
    if User.where(login: mobile).exists?
      flash.now[:error] = '该手机已注册'
      return render :binding_mobile
    end
    mobile_captcha = user_params.delete(:code)
    current_user.code = mobile_captcha
    MobileCaptcha.verify(mobile, mobile_captcha).if_success {
      if current_user.update_with_password(user_params)
        MobileCaptcha.where(mobile: mobile).delete_all
        redirect_to edit_admin_account_path, notice: "绑定手机 #{mobile} 成功"
      else
        flash.now[:error] = model_errors(current_user).join('<br/>') if current_user.errors.any?
        render :binding_mobile
      end
    }.if_failure {
      flash.now[:error] = '手机验证码错误'
      render :binding_mobile
    }
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
