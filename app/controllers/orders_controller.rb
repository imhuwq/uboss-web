class OrdersController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create, :ship_price]
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
    @seller = @order.seller
    @order_items = @order.order_items
    render layout: 'mobile'
  end

  def new
    if browser.wechat? && session['devise.wechat_data'].blank?
      authenticate_user!
    end

    @order_form = OrderForm.new(
      buyer: current_user,
      amount: params[:amount] || 1,
      product_id: params[:product_id],
      product_inventory_id: params[:product_inventory_id]
    )

    set_user_address

    if check_buy_now?  # 直接购买
      product = @order_form.product
      @order_form.sharing_code = get_product_or_store_sharing_code(product)
      @products_group_by_seller =  @order_form.product_inventory.convert_into_cart_item(@order_form.amount, @order_form.sharing_code)

      province = @order_form.user_address.province
      @invalid_items = province.present? && !Order.valid_to_sales?(product, ChinaCity.get(province)) ?
        @products_group_by_seller[product.user] : []

      if product.is_official_agent? && current_user && current_user.is_agent?
        flash[:error] = "您已经是UBOSS创客，请勿重复购买"
        redirect_to root_path
      else
        render layout: 'mobile'
      end
    elsif current_user && params[:item_ids]
      item_ids = params[:item_ids].split(',')
      cart_items = current_cart.cart_items.find(item_ids)
      valid_items = Order.valid_items(cart_items, @order_form.user_address.province)
      session[:valid_items_ids] = valid_items.map(&:id)
      session[:cart_item_ids] = item_ids
      @invalid_items = cart_items - valid_items
      @order_form.cart_id = current_cart.id
      @products_group_by_seller = CartItem.group_by_seller(cart_items)

      render layout: 'mobile'
    else
      redirect_to root_path
    end
  end

  def create
    unless params[:order_form][:product_id].present?
      cart = current_cart
      cart_item_ids = session[:valid_items_ids]
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
      province = @order_form.user_address.try(:province) || params[:province]
      if !Order.valid_to_sales?(@order_form.product, ChinaCity.get(province))
        redirect_to root_path
        return
      end
    elsif cart_item_ids.blank?
      redirect_to root_path
      return
    end

    if @order_form.save
      sign_in(@order_form.buyer) if current_user.blank?
      clean_current_cart unless params[:order_form][:product_id].present?
      @order_title = '确认订单'
      redirect_to payments_charges_path(order_ids: @order_form.order.map(&:id).join(','), showwxpaytitle: 1)
    else
      @order_form.captcha = nil
      flash[:error] = @order_form.errors.full_messages.join('<br/>')

      if check_buy_now?
        redirect_to new_order_path(product_id: @order_form.product_id, product_inventory_id: @order_form.product_inventory_id, amount: @order_form.amount)
      elsif current_user && session[:cart_item_ids].present?
        redirect_to new_order_path(item_ids: session[:cart_item_ids].join(','))
      else
        redirect_to root_path
      end
    end
  end

  def received
    if @order.sign!
      flash[:success] = '已确认收货'
      redirect_to account_path
    end
  end

  def ship_price
    user_address = UserAddress.find_by(id: params[:user_address_id]) || UserAddress.new(province: params[:province])

    if params[:product_id].blank?
      cart_items = current_cart.cart_items.find(session[:cart_item_ids])
      valid_items = Order.valid_items(cart_items, user_address.province)
      session[:valid_items_ids] = valid_items.map(&:id)
      invalid_items = cart_items - valid_items
      ship_prices = []
      CartItem.group_by_seller(valid_items).each do |seller, items|
        ship_prices << [seller.id, Order.calculate_ship_price(items, user_address).to_s]
      end
      render json: { status: 'ok', type: 0, ship_price: ship_prices, invalid_items: json_of(invalid_items), valid_item_ids: session[:valid_items_ids] }
    elsif !params[:count].blank?
      product = Product.find(params[:product_id])
      ship_price = product.calculate_ship_price(params[:count].to_i, user_address)
      invalid_items = !Order.valid_to_sales?(product, ChinaCity.get(user_address.province)) ?
        [CartItem.new(product_inventory_id: params[:product_inventory_id], seller_id: product.user_id, count: params[:count])] : []
      render json: { status: 'ok', type: (invalid_items.blank? ? 1 : 2), ship_price: [[product.user_id, ship_price.to_s]], invalid_items: json_of(invalid_items) }
    end
  end

  private

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
    params.require(:order_form).permit(OrderForm::ATTRIBUTES)
  end

  def find_order
    @order = current_user.orders.find(params[:id])
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

  def check_buy_now?
    @order_form.product_id.present? &&
      @order_form.product_inventory_id.present? &&
      @order_form.amount.present?
  end
end
