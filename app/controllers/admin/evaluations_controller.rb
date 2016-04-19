class Admin::EvaluationsController < AdminController
  load_and_authorize_resource

  def index
    @order_items = OrderItem.joins(:service_product).merge(current_user.service_products)
    filter_type_by_params
    total
  end

  def dishes_index
    @dishes_orders = current_user.dishes_orders.includes(:order_items).completed
    total
  end

  def dishes
    @dishes = DishesProduct.where(user_id: current_user.id)
    total
  end

  def statistics
    @service_products = ServiceProduct.where(user_id: current_user.id)
    total
  end

  def destroy
    @evaluation = Evaluation.find(params[:id])
    if @evaluation.destroy
      flash[:success] = '删除成功'
    else
      flash[:error] = '删除失败'
    end
    redirect_to admin_evaluations_path
  end

  private
  def filter_type_by_params
    if params[:type] == 'good'
      @order_items = @order_items.includes(:evaluations).where(evaluations: {status: [
        Evaluation.statuses[:good], Evaluation.statuses[:better], Evaluation.statuses[:best]]})
    elsif params[:type] == 'bad'
      @order_items = @order_items.includes(:evaluations).where(evaluations: {status: [
        Evaluation.statuses[:worst], Evaluation.statuses[:bad]
      ]})
    end
  end

  def total
    service_products = ServiceProduct.where(user_id: current_user.id)
    @total_good_reputation = service_products.sum('COALESCE(good_evaluation,0) + COALESCE(better_evaluation,0) + COALESCE(best_evaluation,0)')
    @total_bad_reputation = service_products.sum('COALESCE(bad_evaluation,0) + COALESCE(worst_evaluation,0)')
    total_evalution = @total_good_reputation + @total_bad_reputation
    rate = total_evalution > 0 ? @total_good_reputation/total_evalution.to_f : 1
    @total_good_reputation_rate = "#{'%.2f' % (rate*100)}%"
  end
end
