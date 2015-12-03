class Admin::VerifyCodesController < AdminController
  load_and_authorize_resource

  def index
    @verify_codes = VerifyCode.all.reorder(verified: 'desc').order(updated_at: 'desc')
    @total = VerifyCode.total.size
    @today = VerifyCode.today.size
  end

  def statistics
    @service_products = current_user.service_store.service_products
    @total = VerifyCode.total.size
    @today = VerifyCode.today.size
  end

  def verify
    @verify_code = VerifyCode.where(code: params[:code], service_product_id: current_user.service_store.service_product_ids).first

    if @verify_code.present? && @verify_code.verify_code
      flash[:success] = '验证成功'
    else
      flash[:error] = '验证失败'
    end
    redirect_to admin_verify_codes_path
  end
end
