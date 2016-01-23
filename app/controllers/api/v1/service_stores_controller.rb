class Api::V1::ServiceStoresController < ApiBaseController

  def verify
    @verify_code = VerifyCode.with_user(current_user).find_by(code: params[:code])

    if @verify_code.present? && @verify_code.verify_code
      head(200)
    else
      render_error :validation_failed, '验证失败'
    end
  end

  def today_verify_detail
    @today = VerifyCode.today(current_user)
  end

  def total_verify_detail
    @total = VerifyCode.total(current_user)
  end
end
