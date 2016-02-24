class Admin::OrderItemRefundsController < AdminController

  load_and_authorize_resource

  before_action :find_order_item_and_refund,    only: [:approved_refund, :approved_return, :confirm_received,
                                                       :declined_refund, :declined_return, :declined_receive,
                                                       :applied_uboss, :uboss_cancel, :refund_message]
  before_action :refund_reason_must_be_present, only: [:declined_refund, :declined_return, :declined_receive]

  def index
    @order_item = current_user.sold_ordinary_order_items.find(params[:order_item_id])
    @order_item_refund = @order_item.last_refund
    @refund_message = RefundMessage.new
    @order_item_refund.deal_with_timeout_refund
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
    if address = current_user.seller_addresses.find_by(id: params[:return_address])
      @order_item_refund.address = address.refund_label
      @order_item_refund.return_explain = params[:return_explain]
    end

    if @order_item_refund.save && @order_item_refund.may_approve? && @order_item_refund.approve!
      message = "卖家退货地址【#{@order_item_refund.address}】</br>退货说明：#{@order_item_refund.return_explain}"
      create_refund_message({action: '同意退货', message: message})
      flash[:success] = '同意退货申请操作成功'
    else
      flash[:error] = '同意退货申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 确认收货
  def confirm_received
    if @order_item_refund.may_confirm_receive? && @order_item_refund.confirm_receive!
      create_refund_message({action: '确认收货'})
      flash[:success] = '确认收货操作成功'
    else
      flash[:error] = '确认收货操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 拒绝退款
  def declined_refund
    if @order_item_refund.may_decline? && @order_item_refund.decline!
      create_declined_refund_message('拒绝退款')
      flash[:success] = '拒绝退款申请操作成功'
    else
      flash[:error] = '拒绝退款申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 拒绝退货
  def declined_return
    if @order_item_refund.may_decline? && @order_item_refund.decline!
      create_declined_refund_message('拒绝退款')
      flash[:success] = '拒绝退货申请操作成功'
    else
      flash[:error] = '拒绝退货申请操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 拒绝收货
  def declined_receive
    if @order_item_refund.may_decline_receive? && @order_item_refund.decline_receive!
      create_declined_refund_message('拒绝收货')
      flash[:success] = '拒绝收货操作成功'
    else
      flash[:error] = '拒绝收货操作失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  def applied_uboss
    if @order_item_refund.may_apply_uboss? && @order_item_refund.apply_uboss!
      create_refund_message({action: '卖家申请了UBOSS介入' })
      flash[:success] = '申请UBOSS介入成功'
    else
      flash[:error] = '申请UBOSS介入失败'
    end
    redirect_to admin_order_item_order_item_refunds_path(@order_item)
  end

  # 撤销申请（UBOSS介入）
  def uboss_cancel
    if current_user.is_super_admin?
      if @order_item_refund.may_cancel? && @order_item_refund.cancel!
        create_refund_message({ action: 'UBOSS介入撤销了申请' })
        flash[:success] = '退款申请撤销成功'
      else
        flash[:error] = '退款申请撤销失败'
      end
      redirect_to admin_order_item_order_item_refunds_path(@order_item)
    else
      flash[:error] = '没有操作权限'
      redirect_to admin_root_path
    end
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
    @order_item = current_user.sold_ordinary_order_items.find(params[:order_item_id])
    @order_item_refund = @order_item.order_item_refunds.find(params[:id])
  end

  def create_refund_message(options={})
    options.merge!({order_item_refund: @order_item_refund, user_type: (current_user.is_super_admin? ? "管理员" : "卖家"), user_id: current_user.id})
    RefundMessage.create options
  end

  def create_declined_refund_message(action)
    message = "#{params[:refund_message][:refund_reason]}</br>#{params[:refund_message][:explain]}"
    create_refund_message({action: action, message: message, asset_imgs: refund_message_images})
  end

  def refund_message_images
    avatars = params.require(:refund_message).permit(:avatar)
    avatars[:avatar].split(',').inject([]){ |images, avatar|
      images << AssetImg.find_or_create_by(resource: @refund, avatar: avatar)
    }
  end

  def refund_reason_must_be_present
    if params[:refund_message][:refund_reason].blank?
      flash[:error] = '操作失败，请选择您拒绝的原因'
      redirect_to admin_order_item_order_item_refunds_path(@order_item)
    end
  end
end
