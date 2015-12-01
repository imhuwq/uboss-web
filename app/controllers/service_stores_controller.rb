class ServiceStoresController < ApplicationController
  layout 'mobile'

  def show
    @service_store = current_user.service_store
  end

  def verify_detail
    @verify_codes = VerifyCode.all.where(verified: true)
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
    redirect_to service_store_path
  end
end
