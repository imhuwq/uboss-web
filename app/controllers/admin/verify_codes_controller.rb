class Admin::VerifyCodesController < AdminController
  load_and_authorize_resource

  def index
    if params[:type] == 'today'
      @verify_codes = VerifyCode.today(current_user) + VerifyCode.activity_today(current_user)
      @total = VerifyCode.total(current_user).size + VerifyCode.activity_total(current_user).size
      @today = @verify_codes.size
    else
      @verify_codes = VerifyCode.total(current_user) + VerifyCode.activity_total(current_user)
      @total = @verify_codes.size
      @today = VerifyCode.today(current_user).size + VerifyCode.activity_today(current_user).size
    end
  end

  def dishes
    @dishes = DishesProduct.where(user_id: current_user.id)
  end

  def statistics
    @service_products = ServiceProduct.where(user_id: current_user.id)
    @total = VerifyCode.total(current_user).size + VerifyCode.activity_total(current_user).size
    @today = VerifyCode.today(current_user).size + VerifyCode.activity_today(current_user).size
  end

  def verify
    result = VerifyCode.verify(current_user, params[:code])
    if result[:success]
      flash[:success] = result[:message]
    else
      flash[:error] = '验证失败'
    end
    redirect_to admin_verify_codes_path
  end
end
