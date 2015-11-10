class AccountsController < ApplicationController

  detect_device only: [:new_password, :set_password]

  layout :login_layout, only: [:merchant_confirm]

  before_action :authenticate_user!
  before_action :authenticate_agent, only: [:send_message, :invite_seller, :edit_seller_note, :update_histroy_note]

  def show
    @orders = append_default_filter account_orders(params[:state]), page_size: 10
    @privilege_cards = append_default_filter current_user.privilege_cards, order_column: :updated_at, page_size: 10
    render layout: 'mobile'
  end

  def orders
    @orders = append_default_filter account_orders(params[:state]), page_size: 10
    render partial: 'accounts/order', collection: @orders
  end

  def edit
    render layout: 'mobile'
  end

  def update
    user_params = params.require(:user).permit(:nickname)
    if current_user.update(user_params)
      flash[:notice] = '修改成功'
      redirect_to action: :edit
    else
      render :edit
    end
  end

  def new_password
    if flash[:new_password_enabled] != true
      redirect_to after_sign_in_path_for(current_user, need_new_passowrd: false)
    else
      render layout: new_login_layout
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
      render :new_password, layout: new_login_layout
    end
  end

  def merchant_confirmed
    if current_user.is_seller?
      flash[:notice] = '您已经是UBOSS商家'
      redirect_to after_sign_in_path_for(current_user)
    else
      current_user.bind_agent(nil)
      redirect_to binding_agent_admin_account_path
    end
  end

  def password
    render layout: 'mobile'
  end

  def edit_password # 修改密码页面
    render layout: 'mobile'
  end

  def binding_agent # 商家绑定创客
    render layout: 'mobile'
  end

  def update_password
    user_params = params.require(:user).permit(:password, :password_confirmation, :current_password, :code)
    if current_user.need_reset_password
      user_params.delete(:current_password)
      auth_code = user_params.delete(:code)
      if MobileCaptcha.auth_code(current_user.login, auth_code)
        current_user.update(user_params.merge(need_reset_password: false))
        MobileCaptcha.where(mobile: current_user.login).delete_all
        sign_in current_user, bypass: true
        redirect_to settings_account_path, notice: '修改密码成功'
      else
        flash.now[:error] = '验证码错误'
        render :edit_password,layout:'mobile'
      end
    elsif current_user.update_with_password(user_params)
      sign_in current_user, bypass: true
      redirect_to settings_account_path, notice: '修改密码成功'
    else
      flash.now[:error] = current_user.errors.full_messages.join('<br/>')
      render :edit_password,layout:'mobile'
    end
  end

  def reset_password
    current_user.update(need_reset_password: true)
    redirect_to edit_password_account_path
  end

  def invite_seller # 创客通过短信邀请的商家
    @histroys = AgentInviteSellerHistroy.where(agent_id: current_user.id)
    @bind = User.where(agent_id: current_user, authenticated: 1).count
    render layout: 'mobile'
  end

  def edit_seller_note # 编辑发送信息备注
    @histroy = AgentInviteSellerHistroy.find(params[:id])
    render layout: 'mobile'
  end

  def update_histroy_note # 修改发送信息备注
    note = params[:histroy][:note] rescue nil
    histroy = AgentInviteSellerHistroy.find_by(id: params[:id])
    if histroy.present? && note.present? && histroy.agent_id == current_user.id
      histroy.update_columns(note: note)
      flash[:success] = '修改成功'
    else
      flash[:error] = "修改失败#{histroy.errors.messages}."
    end
    redirect_to action: :invite_seller
  end

  def send_message # 保存发送短信给商家的信息
    @histroys = AgentInviteSellerHistroy.where(agent_id: current_user.id)
    mobile = params[:mobile]
    seller = User.find_by(login: mobile)

    if seller && seller.agent_id == current_user.id
      flash.now[:error] = "#{seller.identify}已经是您的商家"
    elsif seller && !seller.can_rebind_agent?
      flash.now[:error] = model_errors(seller).join("<br/>")
    else
      histroy = AgentInviteSellerHistroy.find_or_new_by_mobile_and_agent_id(mobile, current_user.id)
      result = PostMan.send_sms(mobile, {code: histroy.invite_code}, 923_651)
      if result[:success]
        histroy.save
        flash.now[:success] = "您的邀请码已经发送到：#{mobile}."
      else
        flash.now[:error] = result[:message]
      end
    end

    respond_to do |format|
      format.html { render nothing: true }
      format.js
    end
  end

  def bind_seller # 创客绑定商家
    histroy = AgentInviteSellerHistroy.find_by(invite_code: params[:bind_seller][:invite_code], agent_id: current_user.id)
    @seller = User.find_by(login: histroy.mobile) if histroy

    if !histroy || histroy.expired?
      flash[:error] = '验证码错误或已过期。'
    elsif @seller && !@seller.can_rebind_agent?
      flash[:error] = model_errors(@seller).join("<br/>")
    elsif histroy.agent_id != current_user.id
      flash[:error] = '请先邀请商家后绑定'
    else
      @seller ||= User.create_guest(histroy.mobile)
      if current_user.bind_seller(@seller)
        histroy.try(:update, status: 1)
        flash[:success] = "绑定成功,#{@seller.identify}成为您的商家。"
      else
        flash[:error] = model_errors(current_user).join('<br/>')
      end
    end

    redirect_to action: :invite_seller
  end

  def bind_agent # 商家绑定创客
    if !current_user.can_rebind_agent?
      redirect_to action: :binding_agent
    elsif not MobileCaptcha.auth_code(current_user.login, params[:user][:mobile_auth_code])
      flash[:error] = '验证码错误或已过期。'
      redirect_to action: :binding_agent, agent_code: params[:agent_code]
    else
      if current_user.bind_agent(params[:agent_code])
        AgentInviteSellerHistroy.find_by(mobile: current_user.login, agent_id: current_user.agent_id).
          try(:update, status: 1)
        MobileCaptcha.find_by(code: params[:user][:mobile_auth_code]).try(:destroy)
        flash[:success] = "绑定成功,#{current_user.agent.identify}成为您的创客。"
        redirect_to action: :binding_successed
      else
        flash[:error] = model_errors(current_user).join('<br/>')
        redirect_to action: :binding_agent, agent_code: params[:agent_code]
      end
    end
  end

  def settings
    render layout: 'mobile'
  end

  def seller_agreement
    render layout: 'mobile'
  end

  def binding_successed
    render layout: 'mobile'
  end
  private

  def account_orders(type)
    type ||= 'all'
    if ["unpay", "payed", "shiped", "signed", "all"].include?(type)
      current_user.orders.try(type).includes(order_items: { product_inventory: { product: :asset_img } })
    else
      raise "invalid orders state"
    end
  end

  def authenticate_agent # 创客可以使用的action
    unless current_user.is_agent?
      flash[:error] = '您还不是创客.'
      redirect_to action: :settings
    end
  end
end
