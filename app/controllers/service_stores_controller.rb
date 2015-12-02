class ServiceStoresController < ApplicationController
  layout 'mobile'

  def share
  end

  def show
    @service_store = current_user.service_store
  end

  def verify_detail
    @verify_codes = VerifyCode.total
    @total = VerifyCode.total.size
    @today = VerifyCode.today.size
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
