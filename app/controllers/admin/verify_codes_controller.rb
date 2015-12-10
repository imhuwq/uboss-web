class Admin::VerifyCodesController < AdminController
  load_and_authorize_resource

  def index
    order_item_ids = OrderItem.where(product_id: current_user.service_product_ids)
    @verify_codes = VerifyCode.where(order_item_id: order_item_ids).reorder(verified: 'desc').order(updated_at: 'desc')
    @total = VerifyCode.total(current_user).size
    @today = VerifyCode.today(current_user).size
  end

  def statistics
    @order_items = OrderItem.where(product_id: current_user.service_product_ids)
    @total = VerifyCode.total(current_user).size
    @today = VerifyCode.today(current_user).size
  end

  def verify
    order_item_ids = OrderItem.where(product_id: current_user.service_product_ids)
    @verify_code = VerifyCode.where(code: params[:code], order_item_id: order_item_ids).first

    if @verify_code.present? && @verify_code.verify_code
      flash[:success] = '验证成功'
    else
      flash[:error] = '验证失败'
    end
    redirect_to admin_verify_codes_path
  end
end
