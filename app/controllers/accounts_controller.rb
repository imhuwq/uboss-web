class AccountsController < ApplicationController

  include WechatRewarable

  detect_device only: [:new_password, :set_password]

  layout 'mobile', only: [:show, :income, :bonus_benefit, :edit, :password, :edit_password, :invite_seller, :edit_seller_note, :settings, :seller_agreement, :binding_successed]

  before_action :record_scene_identify, only: [:show]
  before_action :authenticate_user!
  before_action :authenticate_agent, only: [:send_message, :invite_seller, :edit_seller_note, :update_histroy_note]

  def show
    @service_orders  = ServiceOrder.where(user_id: current_user.id)
    @ordinary_orders = OrdinaryOrder.where(user_id: current_user.id)

    @statistics = {}
    @statistics[:so_unpay]               = @service_orders.unpay.count
    @statistics[:so_payed]               = @service_orders.payed.count
    @statistics[:so_payed_join_activity] = @service_orders.payed.count + VerifyCode.activity_noverified_total_for_customer(current_user).size
    @statistics[:so_unevaluate]          = so_unevaluate(@service_orders).count

    @statistics[:oo_unpay]               = @ordinary_orders.unpay.count
    @statistics[:oo_shiped]              = @ordinary_orders.shiped.count
    @statistics[:oo_unevaluate]          = oo_unevaluate(@ordinary_orders).count
    @statistics[:oo_after_sale]          = current_user.order_item_refunds.progresses.count

    @privilege_cards = append_default_filter current_user.privilege_cards.includes(:user, [seller: [:service_store, :ordinary_store]]), order_column: :updated_at, page_size: 10

    render layout: 'mobile'
  end

  def refunds
    @refunds = append_default_filter current_user.order_item_refunds.progresses, page_size: 10
    render partial: 'accounts/refund', collection: @refunds
  end

  def orders
    if params[:state] == 'after_sale'
      @refunds = append_default_filter(
        current_user.order_item_refunds.progresses.includes(order_item: [:product, :order]),
        page_size: 10)
    elsif params[:state] == 'unevaluate'
      @orders = append_default_filter(oo_unevaluate(current_user.ordinary_orders).page(params[:page]), page_size: 10)
    else
      @orders = append_default_filter(account_orders(params[:state]), page_size: 10)
    end

    if request.xhr?
      if params[:state] == 'after_sale'
        render partial: 'accounts/refund', collection: @refunds
      else
        render partial: 'accounts/order', collection: @orders
      end
    else
      if params[:state] == 'after_sale'
        render 'accounts/order_after_sale', layout: 'mobile'
      else
        render :orders, layout: 'mobile'
      end
    end
  end

  def service_orders
    @orders = append_default_filter account_service_orders(params[:state]), page_size: 10

    if request.xhr?
      render partial: 'accounts/service_order', collection: @orders
    else
      render :service_orders, layout: 'mobile'
    end
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
    else
      flash[:error] = current_user.errors.full_messages.join('<br/>') unless current_user.bind_agent(nil)
    end
    redirect_to (current_user.is_seller? ? new_admin_product_path : admin_products_path)
  end

  def password
  end

  def update_password
    user_params = params.require(:user).permit(:password, :password_confirmation, :current_password, :code)
    if current_user.need_reset_password || params[:need_reset_password] == 'true'
      user_params.delete(:current_password)
      auth_code = user_params.delete(:code)
      if MobileCaptcha.auth_code(current_user.login, auth_code)
        current_user.update(user_params.merge(need_reset_password: false))
        MobileCaptcha.where(mobile: current_user.login).delete_all
        sign_in current_user, bypass: true
        redirect_to settings_account_path, notice: '修改密码成功'
      else
        flash.now[:error] = '验证码错误'
        render :edit_password, layout:'mobile'
      end
    elsif current_user.update_with_password(user_params)
      sign_in current_user, bypass: true
      redirect_to settings_account_path, notice: '修改密码成功'
    else
      flash.now[:error] = current_user.errors.full_messages.join('<br/>')
      render :edit_password, layout:'mobile'
    end
  end

  def invite_seller # 创客通过短信邀请的商家
    @histroys = AgentInviteSellerHistroy.where(agent_id: current_user.id)
    @bind = current_user.seller_total_joins.count
  end

  def edit_seller_note # 编辑发送信息备注
    @histroy = AgentInviteSellerHistroy.find(params[:id])
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
        flash[:error] = model_errors(@seller).join('<br/>')
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

  def merchant_confirm
    render layout: login_layout
  end

  private
  def so_unevaluate(service_orders)
    service_orders.unevaluate
  end

  def oo_unevaluate(ordinary_orders)
    order_item_ids = OrderItem.where(order_id: ordinary_orders.ids).ids
    ordinary_orders.can_evaluate.where.not(id: ordinary_orders.includes(order_items: [:evaluations]).where(evaluations: {order_item_id: order_item_ids}).ids)
  end

  def account_orders(type)
    type ||= 'all'
    if ["unpay", "payed", "shiped", "signed", "completed", "all"].include?(type)
      current_user.ordinary_orders.try(type).includes(order_items: { product_inventory: { product: :asset_img } })
    else
      raise "invalid orders state"
    end
  end

  def account_service_orders(type)
    type ||= 'all'
    if ["unpay", "payed", "completed", "all"].include?(type)
      ServiceOrder.where(user_id: current_user.id).try(type).includes(order_items: { product_inventory: { product: :asset_img } })
    elsif type == 'unevaluate'
      so_unevaluate(ServiceOrder.where(user_id: current_user.id)).includes(order_items: { product_inventory:{ product: :asset_img } })
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

  def record_scene_identify
    session[:scene_identify] = params[:scene_identify] if params[:scene_identify].present?
  end
end
