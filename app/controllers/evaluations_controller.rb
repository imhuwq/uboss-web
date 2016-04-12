class EvaluationsController < ApplicationController
  before_action :authenticate_user!

  def new
    if params[:id].present?
      @order_item = current_user.order_items.find(params[:id])
      @evaluation = Evaluation.new(order_item: @order_item)
    else
      @order = current_user.orders.find(params[:order_id])
      @evaluation = Evaluation.new(order: @order)
    end
    @stale_form_check_timestamp = Time.now.to_i
    render layout: 'mobile'
  end

  def append
    if params[:type] != 'Order'
      @order_item = current_user.order_items.find(params[:id])
      @evaluations = @order_item.evaluations.where(buyer_id: current_user.id)
    else
      @order = current_user.orders.find(params[:id])
      @evaluations = @order.evaluations.where(buyer_id: current_user.id)
    end
    @evaluation = @evaluations.first.dup
    @stale_form_check_timestamp = Time.now.to_i
    render layout: 'mobile'
  end

  def show
    @evaluation = Evaluation.find(params[:id])
    @product = @evaluation.product
    @sharing_link_node = @evaluation.order_item.sharing_link_node if @evaluation.order_item_id.present?
    render layout: 'mobile'
  end

  def create
    @evaluation = Evaluation.new(validate_attrs)
    if (session[:last_created_at].to_i > params[:timestamp].to_i) ||
      (params[:type] == 'new' && Evaluation.has_evaluationed(@evaluation.order_item_id).present?)
      flash[:error] = '您已经提交, 不能多次提交'
      redirect_to service_orders_account_path
    else
      @stale_form_check_timestamp = Time.now.to_i
      session[:last_created_at] = @stale_form_check_timestamp

      if @evaluation.save
        flash[:success] = '评价成功'
        redirect_to action: :show, id: @evaluation.id
      else
        flash[:error] = @evaluation.errors.full_messages.join('<br/>')
        render action: :new, id: params[:id], layout: 'mobile'
      end
    end
  end

  private
  def validate_attrs
    if params[:evaluation].present?
      params.require(:evaluation).permit(:content, :status, :order_item_id, :order_id)
    end
  end
end
