class SalesReturnsController < ApplicationController

  before_action :authenticate_user!
  before_action :find_order_item, :find_order_item_refund

  layout 'mobile'

  def new
    @sales_return = SalesReturn.new
  end

  def create
    @sales_return = SalesReturn.new(sales_return_params)
    add_multi_img
    if @refund.may_complete_express_number? && @sales_return.save && @refund.complete_express_number!
      flash[:success] = '退货信息保存成功'
    else
      flash[:error] = '退款信息保存失败'
    end
      redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
  end

  def edit
    @sales_return = current_user.sales_returns.find(params[:id])
  end

  def update
    @sales_return = current_user.sales_returns.find(params[:id])
    add_multi_img
    if @sales_return.update(sales_return_params)
      flash[:success] = '退货信息更新成功'
    else
      flash[:error] = '退款信息更新失败'
    end
    redirect_to order_item_order_item_refund_path(order_item_id: @order_item.id, id: @refund.id)
  end

  private
  def find_order_item_refund
    @refund = current_user.order_item_refunds.find(params[:order_item_refund_id])
  end

  def find_order_item
    @order_item = current_user.order_items.find(params[:order_item_id])
  end

  def add_multi_img
    avatars = params.require(:sales_return).permit(:avatar)
    @sales_return.asset_imgs.clear
    avatars[:avatar].split(',').each do |avatar|
      @sales_return.asset_imgs << AssetImg.find_or_create_by(resource: @sales_return, avatar: avatar)
    end
  end

  def sales_return_params
    params.require(:sales_return).
      permit(:logistics_company, :ship_number, :description).
      merge(order_item_refund_id: @refund.id)
  end
end
