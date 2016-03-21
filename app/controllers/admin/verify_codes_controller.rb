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

  def dishes
    @dishes = DishesProduct.where(user_id: current_user.id)
    @total = VerifyCode.total(current_user).size
    @today = VerifyCode.today(current_user).size
  end

  def statistics
    @service_products = ServiceProduct.where(user_id: current_user.id)
    @total = VerifyCode.total(current_user).size
    @today = VerifyCode.today(current_user).size
  end

  def verify
    @verify_code = VerifyCode.with_user(current_user).find_by(code: params[:code])

    if @verify_code.present? && @verify_code.verify_code
      flash[:success] = '验证成功'
    else
      flash[:error] = '验证失败'
    end
    redirect_to admin_verify_codes_path
  end
end
