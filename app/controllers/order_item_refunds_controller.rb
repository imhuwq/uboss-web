class OrderItemRefundsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_order_item
  before_action :find_order_item_refund, only: [:show, :edit, :update, :close]
  layout 'mobile'

  def new
    @refund = OrderItemRefund.new(refund_type: params[:refund_type])
  end

  def service_select
  end

  def edit
  end

  def close
    if @refund.may_cancel? && @refund.cancel!
      flash[:success] = '退款撤销成功'
    else
      flash[:error] = '退款撤销失败'
    end
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
  end

  def update
    add_multi_img
    if @refund.update(order_item_refund_params)
      create_refund_message('买家修改了申请')
      flash[:success] = '修改退款成功'
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
    else
      render :edit
    end
  end

  def create
    @refund = @order_item.order_item_refunds.new(order_item_refund_params)
    add_multi_img
    if @refund.save
      create_refund_message('买家发起申请')
      flash[:success] = '申请退款成功'
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
    else
      render :new
    end
  end

  def show
  end

  private
  def create_refund_message(action)
    @refund_message = RefundMessage.create(explain: @refund.description,
                                        action: action,
                                        refund_reason: @refund.refund_reason,
                                        money: @refund.money,
                                        user_type: '买家',
                                        user_id: current_user.id,
                                        )
  end

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
    params.require(:order_item_refund).permit(:money, :refund_reason_id, :description).merge(order_state: @order_item.order.state, user_id: current_user.id)
  end

end
