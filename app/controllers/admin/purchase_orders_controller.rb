class Admin::PurchaseOrdersController < AdminController
  load_and_authorize_resource
  before_action :set_purchase_order, only: [:delivery]
  before_action :find_or_create_express, only: :delivery

  def index
    segment = %w(all payed completed return).include?(params[:segment]) ? params[:segment] : "all"
    @scope = if segment == 'return'
      scope.with_refunds
    else
      scope.send(segment)
    end

    @purchase_orders = @scope.page(params[:page])
  end

  def show
    @purchase_order = scope.find params[:id]
    @order = @purchase_order.order
    @user_addresses = current_user.seller_addresses
    render template: "admin/orders/show"
  end

  def delivery
    @purchase_order.assign_attributes(delivery_params)
    @purchase_order.express_id = @express.id
    if @purchase_order.delivery
      flash[:success] = '发货成功'
    else
      flash[:error] = "发货失败,#{@purchase_order.errors.full_messages.join(';')}"
    end
    redirect_to action: :index
  end

  private
  def set_purchase_order
    @purchase_order = scope.find params[:id]
  end

  def scope
    PurchaseOrder.accessible_by(current_ability)
  end

  def delivery_params
    params.permit(:express_name).merge(params.require(:order).permit(:ship_number))
  end
end
