class OrdersController < ApplicationController
  # before_action :authenticate_weixin_user, only: [:new], if: -> { true || browser.wechat?  }
  before_action :find_order, only: [:show, :pay, :received]

  def show
  end

  def new
    @order_form = OrderForm.new(
      buyer: current_user,
      product_id: params[:product_id],
      sharing_code: params[:sharing_code]
    )
    if current_user && current_user.default_address
      @order_form.user_address_id = current_user.default_address.id
    end
  end

  def create
    @order_form = OrderForm.new(order_params.merge(buyer: current_user))
    if @order_form.save
      sign_in(@order_form.buyer) if current_user.blank?
      redirect_to order_path(@order_form.order)
    else
      render :new
    end
  end

  def pay
    @order_item = @order.order_items.first rescue nil
    if @order.present? && @order.payed? && @order_item.present?
      flash[:success] = '付款成功'
      redirect_to action: :show
    end
  end

  def received
    @order.state = 1
    if @order.save
      flash[:success] = '已确认收货'
      redirect_to controller: :evaluations, action: :new, id: @order.order_items.first.id
    end
  end

  def save_mobile
    mobile = params[:mobile]
    if mobile.present?
      if User.find_by_mobile(mobile).present?
        # TODO
      else
        User.create_guest(mobile)
      end
    end
    respond_to do |format|
      format.html { render nothing: true }
      format.js { render nothing: true }
    end
  end

  private

  def order_params
    params.require(:order_form).permit(OrderForm::ATTRIBUTES)
  end

  def find_order
    @order = Order.find(params[:id])
  end
end
