class Admin::VerifyCodesController < AdminController
  load_and_authorize_resource

  def index
    if params[:type] == 'today'
      @verify_codes = VerifyCode.today(current_user)
    else
      @verify_codes = VerifyCode.total(current_user)
    end
    @total = VerifyCode.total(current_user).size
    @today = VerifyCode.today(current_user).size
  end

  def statistics
    @service_products = ServiceProduct.where(user_id: current_user.id)
    @total = VerifyCode.total(current_user).size
    @today = VerifyCode.today(current_user).size
  end

  def verify
    service_product_ids = ServiceProduct.where(user_id: current_user.id).ids
    order_item_ids = OrderItem.where(product_id: service_product_ids).ids
    @verify_code = VerifyCode.where(code: params[:code], order_item_id: order_item_ids).first

    if @verify_code.present? && @verify_code.verify_code
      flash[:success] = '验证成功'
    else
      flash[:error] = '验证失败'
    end
    redirect_to admin_verify_codes_path
  end
end
