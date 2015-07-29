class EvaluationsController < ApplicationController
  def new
    @order_item = OrderItem.find(params[:id])
    @evaluation = Evaluation.new(order_item: @order_item)
    @privilege_card = PrivilegeCard.find_by(user: current_user, product: @order_item.product, actived: true)
    # if @order_item.evaluation.present?
    #   flash[:success] = "您已经评价过了"
    #   redirect_to root_path
    # end
  end

  def show
    @evaluation = Evaluation.find(params[:id])
    @sharing_node = @evaluation.sharing_node
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
