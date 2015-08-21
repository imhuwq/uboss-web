class AccountsController < ApplicationController
  layout :login_layout, only: [:set_password, :new_password, :merchant_confirm]

  before_action :authenticate_user!
  before_action :authenticate_agent, only: [:send_message, :invite_seller, :edit_seller_note, :update_histroy_note]

  def show
    @orders = append_default_filter account_orders, page_size: 20
  end

  def orders
    @orders = append_default_filter account_orders, page_size: 20
    render partial: 'accounts/order', collection: @orders
  end

  def edit
  end

  def update
    if current_user.update(nickname: params[:user][:nickname])
      flash[:notice] = '修改成功'
      redirect_to action: :edit
    else
      render :edit
    end
  end

  def new_password
    if flash[:new_password_enabled] != true
      redirect_to after_sign_in_path_for(current_user, need_new_passowrd: false)
    end
  end

  def set_password
    password_params = params.require(:user).permit(:password, :password_confirmation)
    if current_user.update(password_params.merge(need_reset_password: false))
      sign_in(current_user, bypass: true)
      flash[:notice] = '密码设定成功'
      redirect_to after_sign_in_path_for(current_user)
    else
      flash.now[:new_password_enabled] = true
      flash.now[:error] = current_user.errors.full_messages.join('<br/>')
      render :new_password
    end
  end

  def merchant_confirmed
    if current_user.is_seller?
      flash[:notice] = '您已经是UBoss商家'
      redirect_to after_sign_in_path_for(current_user)
    else
      current_user.become_uboss_seller
      redirect_to binding_agent_admin_account_path
    end
  end

  def edit_password # 修改密码页面
  end

  def new_agent_binding # 商家绑定创客
    if current_user.agent.present?
      redirect_to action: :binding_success_page
    end
  end

  def update_password
    user_params = params.require(:user).permit(:password, :password_confirmation, :current_password, :code)
    if current_user.need_reset_password
      user_params.delete(:current_password)
      auth_code = user_params.delete(:code)
      if MobileAuthCode.auth_code(current_user.login, auth_code)
        current_user.update(user_params.merge(need_reset_password: false))
        MobileAuthCode.where(mobile: current_user.login).delete_all
        sign_in current_user, bypass: true
        redirect_to settings_account_path, notice: '修改密码成功'
      else
        flash.now[:error] = '验证码错误'
        render :edit_password
      end
    elsif current_user.update_with_password(user_params)
      sign_in current_user, bypass: true
      redirect_to settings_account_path, notice: '修改密码成功'
    else
      flash.now[:error] = current_user.errors.full_messages.join('<br/>')
      render :edit_password
    end
  end

  def reset_password
    current_user.update(need_reset_password: true)
    redirect_to edit_password_account_path
  end

  def invite_seller # 创客通过短信邀请的商家
    @histroys = AgentInviteSellerHistroy.where(agent_id: current_user.id)
    @bind = User.where(agent_id: current_user, authenticated: 1).count
  end

  def edit_seller_note # 编辑发送信息备注
    @histroy = AgentInviteSellerHistroy.find(params[:id])
  end

  def update_histroy_note # 修改发送信息备注
    note = params[:histroy][:note] rescue nil
    histroy = AgentInviteSellerHistroy.find_by(id: params[:id])
    if histroy.present? && note.present? && histroy.agent_id == current_user.id
      histroy.update(note: note)
      flash[:success] = '修改成功'
    else
      flash[:error] = "修改失败#{histroy.errors.messages}."
    end
    redirect_to action: :invite_seller
  end

  def send_message # 保存发送短信给商家的信息
    mobile = params[:send_message][:mobile] rescue nil
    if mobile.present? && mobile =~ /\A(\s*)(?:\(?[0\+]?\d{1,3}\)?)[\s-]?(?:0|\d{1,4})[\s-]?(?:(?:13\d{9})|(?:\d{7,8}))(\s*)\Z|\A[569][0-9]{7}\Z/
      sms = send_sms(mobile, current_user.find_or_create_agent_code, 923_651)
      if sms == 'OK'
        AgentInviteSellerHistroy.find_or_create_by(mobile: mobile) do |obj|
          obj.agent_id = current_user.id
        end
        flash[:success] = "您的创客码已经发送到：#{mobile}."
      else
        flash[:error] = "短信发送失败,#{sms}."
      end
    else
      flash[:error] = '手机格式不正确'
    end
    redirect_to action: :invite_seller
  end

  def binding_agent # 商家绑定创客
    if current_user.agent.present?
      redirect_to action: :binding_success_page
    else
      valid_code
      if @errors.present?
        flash[:error] = @errors.join("\n")
        redirect_to action: :new_agent_binding, agent_code: params[:agent_code]
      else
        current_user.binding_agent(params[:agent_code])
        MobileAuthCode.find_by(code: params[:user][:mobile_auth_code]).try(:destroy)
        redirect_to action: :binding_success_page
      end
    end
  end

  def seller_agreement # 商家协议
  end

  def binding_successed
  end

  private

  def account_orders
    current_user.orders.includes(order_items: { product: :asset_img })
  end

  def valid_code
    @errors = []
    hash = {
      '验证码错误或已过期。' => MobileAuthCode.auth_code(params[:user][:mobile], params[:user][:mobile_auth_code]),
      # '创客邀请码错误。': User.find_by(agent_code: params[:agent_code])
    }
    hash.each do |k, v|
      @errors << k unless v.present?
    end
  end

  def authenticate_agent # 创客可以使用的action
    unless current_user.agent?
      flash[:error] = '您还不是创客.'
      redirect_to action: :settings
    end
  end
end
