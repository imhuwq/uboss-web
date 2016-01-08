class Admin::EvaluationsController < AdminController
  def index
    @order_items = OrderItem.where(product_id: current_user.service_product_ids)
    filter_type_by_params
    total
  end

  def statistics
    @service_products = current_user.service_products
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
    total_evalution = 0.0
    @total_good_reputation = 0
    @total_bad_reputation = 0
    current_user.service_products.each do |product|
      total_evalution += product.good_evaluation.to_f + product.bad_evaluation.to_f + product.worst_evaluation.to_f + product.best_evaluation.to_f + product.better_evaluation.to_f
      @total_good_reputation += product.good_evaluation.to_i + product.best_evaluation.to_i + product.better_evaluation.to_i
      @total_bad_reputation += product.bad_evaluation.to_i + product.worst_evaluation.to_i
    end
    rate = total_evalution > 0 ? @total_good_reputation/total_evalution.to_f : 1
    @total_good_reputation_rate = "#{'%.2f' % (rate*100)}%"
  end
end
