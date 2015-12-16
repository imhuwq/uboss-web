class ServiceStoresController < ApplicationController
  layout 'mobile'

  def share
  end

  def show
    @service_store = current_user.service_store
  end

  def verify_detail
    @verify_codes = VerifyCode.today(current_user)
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
    redirect_to service_store_path
  end
end
