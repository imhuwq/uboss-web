class ServiceOrdersController < ApplicationController
  before_action :authenticate_user_if_browser_wechat, only: [:new]
  before_action :authenticate_user!
  before_action :find_order, only: [:cancel, :show, :pay, :pay_complete, :received]

  def new
    if browser.wechat? && session['devise.wechat_data'].blank?
      authenticate_user!
    end
    @order_form = ServiceOrderForm.new(
      buyer: current_user,
      bind_mobile: current_user.login,
      amount: params[:amount] || 1,
      product_id: params[:product_id],
      product_inventory_id: params[:product_inventory_id],
      sharing_code: get_product_sharing_code(params[:product_id])
    )

    @product = @order_form.product
    @seller = @product.user

    if @product.is_official_agent? && current_user && current_user.is_agent?
      flash[:error] = "您已经是UBOSS创客，请勿重复购买"
      redirect_to root_path
    else
      render layout: 'mobile'
    end
  end

  def create
    @order_form = ServiceOrderForm.new(
      order_params.merge(buyer: current_user, session: session)
    )

    if @order_form.save
      sign_in(@order_form.buyer) if current_user.blank?
      @order_title = '确认订单'
      redirect_to payments_charges_path(order_ids: @order_form.order.map(&:id).join(','), showwxpaytitle: 1)
    else
      @order_form.captcha = nil
      flash[:error] = @order_form.errors.full_messages.join('<br/>')

      redirect_to new_service_order_path(product_id: @order_form.product_id, product_inventory_id: @order_form.product_inventory_id, amount: @order_form.amount)
    end
  end

  def show
    @seller = @order.seller
    @service_store = @seller.service_store
    @order_item = @order.order_items.first
    @sharing_link_node ||=
      SharingNode.find_or_create_by_resource_and_parent(current_user, @seller)
    render layout: 'mobile'
  end

  def cancel
    if @order.may_close? && @order.close!
      flash[:success] = '订单取消成功'
    else
      flash[:errors] = '订单取消失败'
    end
    redirect_to service_order_path(@order)
  end

  private

  def authenticate_user_if_browser_wechat
    if browser.wechat? && session['devise.wechat_data'].blank?
      authenticate_user!
    end
  end

  def order_params
    params.require(:service_order_form).permit(ServiceOrderForm::ATTRIBUTES)
  end

  def find_order
    @order = current_user.service_orders.find(params[:id])
  end
end
