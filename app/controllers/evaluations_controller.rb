class EvaluationsController < ApplicationController
  def new
    @order_item = OrderItem.find(params[:id])
    @evaluation = Evaluation.new(order_item: @order_item)
    render layout: 'mobile'
  end
  
  def append
    render layout: 'mobile'    
  end
  
  def show
    @evaluation = Evaluation.find(params[:id])
    @product = @evaluation.product
    @sharing_node = @evaluation.sharing_node
    @privilege_card = PrivilegeCard.find_by(user: current_user, seller: @product.user, actived: true)
  end

  def index
  end

  def create
    @evaluation = Evaluation.new(validate_attrs)
    if @evaluation.save
      flash[:success] = '评价成功'
      redirect_to action: :show, id: @evaluation.id
    else
      flash[:error] = @evaluation.errors.full_messages.join('<br/>')
      render action: :new, id: params[:id]
    end
  end

  private

  def validate_attrs
    if params[:evaluation].present?
      params.require(:evaluation).permit(:content, :status, :order_item_id)
    end
  end
end
