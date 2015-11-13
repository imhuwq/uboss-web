class Admin::OrderItemRefundsController < AdminController
  load_and_authorize_resource
  before_action :find_order_item_and_refund, only: [:approved_refund, :approved_return, :approved_receive, :declined_refund, :declined_receive, :refund_message]
  before_action :refund_reason_must_be_present, only: [:declined_refund, :declined_return, :declined_receive]

  def index
    @order_item = OrderItem.find(params[:order_item_id])
    @order_item_refund = @order_item.last_refund
    @refund_message = RefundMessage.new
  end

  # 同意退款（待发货时买家申请退款/待收货状态时买家申请退款）
  def approved_refund
    if @order_item_refund.may_approve? && @order_item_refund.approve!
      create_refund_message({action: '同意退款'})
      flash[:success] = '同意退款申请操作成功'
    else
      flash[:error] = '同意退款申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 同意退货
  def approved_return
    @order_item_refund.address = "#TODO 退货地址"

    if @order_item_refund.may_approve? && @order_item_refund.approve!
      #TODO 发送退货地址、退货说明
      message = "退货地址：#{'TODO退货地货'}</br>退货说明：#{params[:return_message]}"
      create_refund_message({action: '同意退货', message: message})
      flash[:success] = '同意退货申请操作成功'
    else
      flash[:error] = '同意退货申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 同意收货
  def approved_receive
    if @order_item_refund.may_confirm_receive? && @order_item_refund.confirm_receive!
      create_refund_message({action: '确认收货'})
      flash[:success] = '同意收货操作成功'
    else
      flash[:error] = '同意收货操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 拒绝退款
  def declined_refund
    if @order_item_refund.may_decline? && @order_item_refund.decline!
      message = "拒绝原因：#{params[:refund_message][:refund_reason_id]}</br>拒绝说明：#{params[:refund_message][:explain]}"
      create_refund_message({action: '拒绝退款', message: message, asset_imgs: refund_message_images})
      flash[:success] = '拒绝退款申请操作成功'
    else
      flash[:error] = '拒绝退款申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 拒绝退货
  def declined_return
    if @order_item_refund.may_decline? && @order_item_refund.decline!
      message = "拒绝原因：#{params[:refund_message][:refund_reason_id]}</br>拒绝说明：#{params[:refund_message][:explain]}"
      create_refund_message({action: '拒绝退款', message: message, asset_imgs: refund_message_images})
      flash[:success] = '拒绝退货申请操作成功'
    else
      flash[:error] = '拒绝退货申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 拒绝收货
  def declined_receive
    if @order_item_refund.may_decline_receive? && @order_item_refund.decline_receive!
      message = "拒绝原因：#{params[:refund_message][:refund_reason_id]}</br>拒绝说明：#{params[:refund_message][:explain]}"
      create_refund_message({action: '拒绝收货', message: message, asset_imgs: refund_message_images})
      flash[:success] = '拒绝收货操作成功'
    else
      flash[:error] = '拒绝收货操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  def refund_message
    if params[:refund_message][:message].blank?
      flash[:error] = '留言内容不能为空'
    elsif create_refund_message({message: params[:refund_message][:message], asset_imgs: refund_message_images})
      flash[:success] = '发表留言成功'
    else
      flash[:error] = '发表留言失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  private

  def find_order_item_and_refund
    @order_item = OrderItem.find(params[:order_item_id])
    @order_item_refund = @order_item.order_item_refunds.find(params[:id])
  end

  def create_refund_message(options={})
    options.merge!({order_item_refund: @order_item_refund, user_type: 'seller', user_id: current_user.id})
    RefundMessage.create options
  end

  def refund_message_images
    avatars = params.require(:refund_message).permit(:avatar)
    avatars[:avatar].split(',').inject([]){ |images, avatar|
      images << AssetImg.find_or_create_by(resource: @refund, avatar: avatar)
    }
  end

  def refund_reason_must_be_present
    if params[:refund_message][:refund_reason_id].blank?
      flash[:error] = '操作失败，请选择一个拒绝原因'
      redirect_to admin_order_item_order_item_refunds_path(@order_item)
    end
  end
end
