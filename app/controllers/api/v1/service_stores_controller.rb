class Api::V1::ServiceStoresController < ApiBaseController
  def today_verify_detail
    @today = VerifyCode.today(current_user)
  end

  def total_verify_detail
    @total = VerifyCode.total(current_user)
  end
end
