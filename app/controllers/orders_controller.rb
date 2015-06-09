class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :pay]

  def show
  end

  def new
    @order_form = OrderForm.new(buyer: current_user, product_id: params[:product_id])
  end

  def create
    @order_form = OrderForm.new(order_params.merge(buyer: current_user))
    if @order_form.save
      redirect_to pay_order_path(@order_form.order)
    else
      render :new
    end
  end

  def pay
  end

  private
  def order_params
    params.require(:order_form).permit!
  end

  def find_order
    @order = Order.find(params[:id])
  end
end
