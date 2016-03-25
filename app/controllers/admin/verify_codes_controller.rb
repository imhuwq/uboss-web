class Admin::VerifyCodesController < AdminController
  load_and_authorize_resource

  def index
    if params[:type] == 'today'
      @verify_codes = VerifyCode.today(current_user) + VerifyCode.activity_today(current_user)
      @total = @verify_codes.size
      @today = VerifyCode.today(current_user).size + VerifyCode.activity_today(current_user).size
    else
      @verify_codes = VerifyCode.total(current_user) + VerifyCode.activity_total(current_user)
      @total = VerifyCode.total(current_user).size + VerifyCode.activity_total(current_user).size
      @today = @verify_codes.size
    end
  end

  def statistics
    @service_products = ServiceProduct.where(user_id: current_user.id)
    @total = VerifyCode.total(current_user).size + VerifyCode.activity_total(current_user).size
    @today = VerifyCode.today(current_user).size + VerifyCode.activity_today(current_user).size
  end

  def verify
    verify_code = VerifyCode.find_by(code: params[:code])
    if verify_code && verify_code.order_item_id
      if VerifyCode.with_user(current_user).find_by(code: params[:code]).verify_code
        flash[:success] = '验证成功'
      else
        flash[:error] = '验证失败'
      end
    elsif verify_code && verify_code.activity_prize
      if verify_code.verify_activity_code(current_user)
        flash[:success] = "#{verify_code.activity_prize.activity_info.name}:验证成功。"
      else
        flash[:error] = '验证失败'
      end
    else
      flash[:error] = '验证失败'
    end
    redirect_to admin_verify_codes_path
  end
end
