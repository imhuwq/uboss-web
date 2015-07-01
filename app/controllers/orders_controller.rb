class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :pay]

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
      redirect_to pay_order_path(@order_form.order)
    else
      render :new
    end
  end

  def pay
    order = Order.find_by_id(params[:id])
    order_item = Order.find_by_id(params[:id]).order_items.first rescue nil
    if order.present? && order.payed? && order_item.present?
      flash[:success] = "付款成功"
      redirect_to action: :show
    end
  end

  def received
    order = Order.find_by_id(params[:id])
    order.state = 1
    if order.save
      flash[:success] = "已确认收货"
      redirect_to controller: :evaluations, action: :new, id: order.order_items.first.id
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
