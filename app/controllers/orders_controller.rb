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
      @privilege_card = PrivilegeCard.find_by(user: current_user, product: @product, actived: true)
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
    )
    @product = @order_form.product
    @order_form.sharing_code = get_product_or_store_sharing_code(@product)
    if @product.is_official_agent? && current_user && current_user.is_agent?
      flash[:error] = "您已经是UBOSS创客，请勿重复购买"
      redirect_to root_path
    else
      if current_user && @default_address = current_user.default_address
        @order_form.user_address_id = @default_address.id
      end
    end
  end

  def create
    @order_form = OrderForm.new(
      order_params.merge(
        buyer: current_user,
        session: session
      )
    )
    @order_form.sharing_code = get_product_or_store_sharing_code(@order_form.product)

    if @order_form.save
      sign_in(@order_form.buyer) if current_user.blank?
      @order_title = '确认订单'
      redirect_to order_path(@order_form.order, showwxpaytitle: 1)
    else
      @order_form.captcha = nil
      @product = @order_form.product
      @user_address = @order_form.user_address
      flash.now[:error] = @order_form.errors.full_messages.join('<br/>')
      render :new
    end
  end

  def pay_complete
    @order.check_paid
    @order_charge = @order.order_charge
    @product = @order.order_items.first.product
    @privilege_card = PrivilegeCard.find_by(user: current_user, product: @product)
  end

  def received
    if @order.sign!
      flash[:success] = '已确认收货'
      redirect_to controller: :evaluations, action: :new, id: @order.order_items.first.id
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
end
