class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :find_order, only: [:cancel, :show, :pay, :pay_complete, :received]

  def cancel
    if @order.may_close? && @order.close!
      flash[:success] = '订单取消成功'
    else
      flash[:errors] = '订单取消失败'
    end
    redirect_to order_path(@order)
  end

  def show
    @order_item = @order.order_items.first
    @product = @order_item.product
    if available_pay?(@order, @product)
      @order_charge = ChargeService.find_or_create_charge(@order, remote_ip: request.ip)
      @pay_p = {
        appId: WxPay.appid,
        timeStamp: Time.now.to_i.to_s,
        nonceStr: SecureRandom.hex,
        package: "prepay_id=#{@order_charge.prepay_id}",
        signType: "MD5"
      }
      @pay_sign = WxPay::Sign.generate(@pay_p)
    elsif @order.signed? || @order.completed?
      @privilege_card = PrivilegeCard.find_by(user: current_user, seller: @product.user, actived: true)
      @sharing_link_node = @order_item.sharing_link_node
    end
  end

  def new
    if browser.wechat? && session['devise.wechat_data'].blank?
      authenticate_user!
    end

    @order_form = OrderForm.new(
      buyer: current_user,
      product_id: params[:product_id],
      product_inventory_id: params[:product_inventory_id],     # TODO 创客权需要设置一个默认的product_inventory
      amount: params[:amount] || 1
    )

    if params[:product_id].present?  # 直接购买
      @product = @order_form.product
      @productInventory = @order_form.product_inventory
      @order_form.sharing_code = get_product_or_store_sharing_code(@product)
      @products_group_by_seller = @productInventory.convert_into_cart_item(@order_form.amount, @order_form.sharing_code)

      if @product.is_official_agent? && current_user && current_user.is_agent?
        flash[:error] = "您已经是UBOSS创客，请勿重复购买"
        redirect_to root_path
      else
        set_user_address
      end
    elsif params[:item_ids]
      item_ids = params[:item_ids].split(',')
      session[:cart_item_ids] = item_ids
      @cart = current_cart
      @cart_items = @cart.cart_items.find(item_ids)
      @order_form.cart_id = @cart_id
      @products_group_by_seller = CartItem.group_by_seller(@cart_items)

      set_user_address
    else
      redirect_to root_path
    end
    render layout: 'mobile'
  end

  def create
    unless params[:order_form][:product_id].present?
      cart = current_cart
      cart_item_ids = session[:cart_item_ids]
      cart_items = cart.cart_items.find(cart_item_ids)
      seller_ids = cart_items.map(&:seller_id).uniq
    end

    @order_form = OrderForm.new(
      order_params.merge(
        cart_item_ids: cart_item_ids,
        seller_ids: seller_ids,
        to_seller: params[:order][:to_seller],
        buyer: current_user,
        session: session
      )
    )

    if @order_form.product_id.present?
      @order_form.sharing_code = get_product_or_store_sharing_code(@order_form.product)
    end

    if @order_form.save
      sign_in(@order_form.buyer) if current_user.blank?
      clean_current_cart unless params[:order_form][:product_id].present?
      @order_title = '确认订单'
      #redirect_to order_path(@order_form.order, showwxpaytitle: 1)
      redirect_to payments_charge_path(OrderCharge.last)
    else
      @order_form.captcha = nil
      @user_address = @order_form.user_address

      if @order_form.product_id
        @product = @order_form.product
      elsif !session[:cart_item_ids].blank?          # 购物车
        @cart = current_cart
        @cart_items = @cart.cart_items.find(session[:cart_item_ids])
      end
      flash.now[:error] = @order_form.errors.full_messages.join('<br/>')
      render :new
    end
  end

  def pay_complete
    @order.check_paid
    @order_charge = @order.order_charge
    @product = @order.order_items.first.product
    @privilege_card = PrivilegeCard.find_by(user: current_user, seller: @product.user)
  end

  def received
    if @order.sign!
      flash[:success] = '已确认收货'
      redirect_to controller: :evaluations, action: :new, id: @order.order_items.first.id
    end
  end

  def ship_price
    user_address = current_user.user_addresses.find_by(id: params[:user_address_id]) || current_user.user_addresses.new(province: params[:province])

    if params[:product_id].blank?
      cart = current_cart
      cart_items = cart.cart_items.find(session[:cart_item_ids])
      ship_prices = []
      CartItem.group_by_seller(cart_items).each do |seller, cart_items|
        ship_prices << [seller.id, Order.calculate_ship_price(cart_items, user_address).to_s]
      end
      render json: { status: 'ok', is_cart: 1, ship_price: ship_prices }
    elsif !params[:count].blank?
      product = Product.find(params[:product_id])
      ship_price = product.calculate_product_ship_price(product, params[:count].to_i, user_address)
      render json: { status: 'ok', is_cart: 0, ship_price: ship_price.to_s }
    end
  end

  private

  def order_params
    params.require(:order_form).permit(OrderForm::ATTRIBUTES)
  end

  def find_order
    @order = current_user.orders.find(params[:id])
  end

  def available_pay?(order, product)
    order.unpay? &&
      browser.wechat? &&
      (product.is_official_agent? ? available_buy_official_agent? : true)
  end
  helper_method :available_pay?

  def available_buy_official_agent?
    current_user && !current_user.is_agent?
  end

  def clean_current_cart
    current_cart.remove_cart_items(session[:cart_item_ids])
    session[:cart_item_ids] = nil
  end

  def set_user_address
    if current_user && @default_address = current_user.default_address
      @order_form.user_address_id = @default_address.id
    end
  end
end
