class Admin::VerifyCodesController < AdminController
  load_and_authorize_resource

  def index
    #TODO
    #@verify_codes = current_user.service_store
    @verify_codes = VerifyCode.where(verified: true)
    @today = @verify_codes.where('updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, DateTime.now.end_of_day).size
    @total = @verify_codes.size
  end

  def statistics
    @verify_codes = VerifyCode.where(verified: true)
    @today = @verify_codes.where('updated_at BETWEEN ? AND ?', Time.now.beginning_of_day, DateTime.now.end_of_day).size
    @total = @verify_codes.size
  end

  def verify
    #TODO
    #@verify_code = current_user.service_store.verify_codes.find_by_code(params[:code])
    @verify_code = VerifyCode.find_by_code(params[:code])

    if @verify_code.present? && @verify_code.verify_code
      flash[:success] = '验证成功'
    else
      flash[:error] = '验证失败'
    end
    redirect_to admin_verify_codes_path
  end
end
