class OrderItemRefundsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_order_item
  before_action :find_order_item_refund, only: [:show, :edit, :update, :consult_info]
  layout 'mobile'

  def new
    @refund = OrderItemRefund.new
  end

  def edit
  end

  def consult_info
  end

  def update
    add_multi_img
    if @refund.update(order_item_refund_params)
      flash[:success] = '修改退款成功'
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
    else
      render :edit
    end
  end

  def create
    @refund = @order_item.order_item_refunds.new(order_item_refund_params)
    add_multi_img
    if @refund.save && @order_item.may_apply_refund? && @order_item.apply_refund!
      flash[:success] = '申请退款成功'
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
    else
      render :new
    end
  end

  def show
  end

  private
  def find_order_item_refund
    @refund = OrderItemRefund.find(params[:id])
  end

  def find_order_item
    @order_item = OrderItem.find(params[:order_item_id])
  end

  def add_multi_img
    avatars = params.require(:order_item_refund).permit(:avatar)
    avatars[:avatar].split(',').each do |avatar|
      @refund.asset_imgs << AssetImg.find_or_create_by(resource: @refund, avatar: avatar)
    end
  end

  def order_item_refund_params
    params.require(:order_item_refund).permit(:money, :refund_reason_id, :description)
  end

end
