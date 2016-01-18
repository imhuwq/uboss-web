class OrderItemRefundsController < ApplicationController

  layout 'mobile'

  before_action :authenticate_user!
  before_action :find_order_item
  before_action :find_order_item_refund, only: [:show, :edit, :update, :close, :apply_uboss]

  def new
    @refund = OrderItemRefund.new(refund_type: params[:refund_type])
  end

  def service_select
  end

  def apply_uboss
    if @refund.may_apply_uboss? && @refund.apply_uboss!
      create_refund_message('买家申请了UBOSS介入')
      flash[:success] = '申请UBOSS成功'
    else
      flash[:error] = '申请UBOSS失败'
    end
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
  end

  def edit
  end

  def close
    if @refund.may_cancel? && @refund.cancel!
      create_refund_message('买家撤销了退款申请')
      flash[:success] = '退款撤销成功'
    else
      flash[:error] = '退款撤销失败'
    end
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
  end

  def update
    add_multi_img
    if @refund.update(order_item_refund_params)
      @refund.declined? && @refund.may_repending? && @refund.repending!
      @refund.decline_received? && @refund.may_complete_express_number? && @refund.complete_express_number!
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
                                        order_item_refund_id: @refund.id,
                                        )
    @refund.asset_imgs.each do |img|
      @refund_message.asset_imgs << AssetImg.create(
        resource: @refund_message,
        avatar: img.avatar.file.filename
      )
    end
  end

  def find_order_item_refund
    @refund = current_user.order_item_refunds.find(params[:id])
  end

  def find_order_item
    @order_item = current_user.order_items.find(params[:order_item_id])
  end

  def add_multi_img
    avatars = params.require(:order_item_refund).permit(:avatar)
    @refund.asset_imgs.clear
    avatars[:avatar].split(',').each do |avatar|
      @refund.asset_imgs << AssetImg.find_or_create_by(resource: @refund, avatar: avatar)
    end
  end

  def order_item_refund_params
    params.require(:order_item_refund).permit(:money, :refund_reason_id, :description, :refund_type).
      merge(order_state: @order_item.order.state, user_id: current_user.id)
  end

end
