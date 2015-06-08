class OrdersController < ApplicationController
  before_action :find_order, only: [:show, :pay]

  def show
  end

  def new
    @order = Order.new(order_params)
  end

  def create
    @order = Order.new(order_params)
    if @order.save
    else
      render
    end
  end

  def pay
  end

  private
  def order_params
    params.require(:order).permit(:pay_message)
  end

  def find_order
    @order = Order.find(params[:id])
  end
end
