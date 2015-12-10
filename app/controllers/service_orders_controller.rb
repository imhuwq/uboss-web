class ServiceOrdersController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create, :ship_price, :change_address]
  before_action :find_order, only: [:cancel, :show, :pay, :pay_complete, :received]
  before_action :authenticate_user_if_browser_wechat, only: [:new]

  def new
    if browser.wechat? && session['devise.wechat_data'].blank?
      authenticate_user!
    end
    @order_form = ServiceOrderForm.new(
      buyer: current_user,
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
    @order_items = @order.order_items
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
    redirect_to order_path(@order)
  end

  def received
    if @order.sign!
      flash[:success] = '已确认收货'
      redirect_to account_path
    end
  end

  def change_address
    user_address = UserAddress.find_by(id: params[:user_address_id]) || UserAddress.new(province: params[:province])

    if params[:product_id].blank?
      cart_items = current_cart.cart_items
        .includes(:sharing_node, product_inventory: [:product])
        .find(session[:cart_item_ids])
      valid_items = OrdinaryOrder.valid_items(cart_items, user_address.province)
      session[:valid_items_ids] = valid_items.map(&:id)
      invalid_items = cart_items - valid_items
      ship_prices = []
      CartItem.group_by_seller(valid_items).each do |seller, items|
        ship_prices << [seller.id, OrdinaryOrder.calculate_ship_price(items, user_address).to_s]
      end
      render json: { status: 'ok', ship_price: ship_prices, invalid_items: json_of(invalid_items), valid_item_ids: session[:valid_items_ids] }
    elsif !params[:count].blank?
      product = OrdinaryProduct.find(params[:product_id])
      ship_price = product.calculate_ship_price(params[:count].to_i, user_address, params[:product_inventory_id])
      invalid_items = !OrdinaryOrder.valid_to_sales?(product, ChinaCity.get(user_address.province)) ?
        [CartItem.new(product_inventory_id: params[:product_inventory_id], seller_id: product.user_id, count: params[:count])] : []
      render json: { status: 'ok', ship_price: [[product.user_id, ship_price.to_s]], invalid_items: json_of(invalid_items) }
    end
  end

  private
  def authenticate_user_if_browser_wechat
    if browser.wechat? && session['devise.wechat_data'].blank?
      authenticate_user!
    end
  end

  def json_of(invalid_items)
    invalid_items.collect { |item| {
      name: item.product_name,
      image_url: item.image_url,
      price: item.price,
      count: item.count,
      sku: item.sku_attr_str
    }}
  end

  def order_params
    params.require(:service_order_form).permit(OrderForm::ATTRIBUTES)
  end

  def find_order
    @order = current_user.service_orders.find(params[:id])
  end

  def clean_current_cart
    current_cart.remove_cart_items(session[:cart_item_ids])
    session[:cart_item_ids] = nil
  end

  def check_buy_now?
    @order_form.product_id.present? &&
      @order_form.product_inventory_id.present? &&
      @order_form.amount.present?
  end
end
