class EvaluationsController < ApplicationController
  def new
    @evaluation = Evaluation.new
  end

  def show
    @evaluation = Evaluation.find_by_id(params[:id])
    @sharing_node = SharingNode.create(user_id: current_user.id, product_id: @evaluation.product_id)
  end

  def index
  end

  def create
    evaluation = Evaluation.new(validate_attrs)
    evaluation.order_item_id = params[:id] || OrderItem.first.try(:id)
    if evaluation.save!
      flash[:success] = '评价成功'
      redirect_to action: :show, id: evaluation.id
    else
      flash[:error] = '评价失败'
      render action: :new, id: params[:id]
    end
  end

  private

  def validate_attrs
    if params[:evaluation].present?
      params.require(:evaluation).permit(:content, :status)
    end
  end
end
