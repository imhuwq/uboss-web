class Admin::OrderItemRefundsController < AdminController
  load_and_authorize_resource
  before_action :find_order_item, only: [:index, :approve_refund, :approve_return, :approve_receive, :decline_refund, :decline_receive]

  def index
  end

  # 同意退款（待发货时买家申请退款/待收货状态时买家申请退款）
  def finish_refund
    order_item = OrderItem.find(params[:order_item_id])
    order_item_refund = order_item.order_item_refunds.find(params[:id])

    if order_item_refund.may_approve? && order_item_refund.approve!
      flash[:success] = '同意退款申请操作成功'
    else
      flash[:errors] = '同意退款申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(order_item)
  end

  # 同意退货
  def approved_return
    order_item = OrderItem.find(params[:order_item_id])
    order_item_refund = order_item.order_item_refunds.find(params[:id])

    #TODO 发送退货地址、退货说明

    if order_item_refund.may_approve? && order_item_refund.approve!
      flash[:success] = '同意退货申请操作成功'
    else
      flash[:errors] = '同意退货申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(order_item)
  end

  # 拒绝退款/退款退货
  def declined_refund
    order_item = OrderItem.find(params[:order_item_id])
    order_item_refund = order_item.order_item_refunds.find(params[:id])

    #TODO 记录拒绝退款申请原因、说明、凭证

    if order_item_refund.may_decline? && order_item_refund.decline!
      flash[:success] = '拒绝退款申请操作成功'
    else
      flash[:errors] = '拒绝退款申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(order_item)
  end

  # 拒绝收货
  def declined_receive
    order_item = OrderItem.find(params[:order_item_id])
    order_item_refund = order_item.order_item_refunds.find(params[:id])

    #TODO 记录拒绝收货申请原因、说明、凭证

    if order_item_refund.may_decline_receive? && order_item_refund.decline_receive!
      flash[:success] = '拒绝收货操作成功'
    else
      flash[:errors] = '拒绝收货操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(order_item)
  end

  private
  def find_order_item
    @refund_message = RefundMessage.new
    @order_item = OrderItem.find(params[:order_item_id])
    @order_item_refund = @order_item.last_refund
  end
end
