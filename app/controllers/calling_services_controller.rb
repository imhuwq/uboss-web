class CallingServicesController < ApplicationController
  before_action :find_seller
  before_action :find_using_table_number,  only: [:index, :notifies, :calling]

  def index
    @calling_services = @seller.calling_services.where("name != ? and name != ?", "结帐", "其它服务")
    @checkout_service = @seller.calling_services.find_or_create_by(name: "结帐")
    @other_service    = @seller.calling_services.find_or_create_by(name: "其它服务")
  end

  def notifies
    @calling_notifies = CallingNotify.where(user: @seller, table_number: @table_number)
  end

  def calling
    @calling_service = @seller.calling_services.find(params[:service_id])
    @calling_notify  = CallingNotify.find_or_initialize_by(user: @seller, table_number: @table_number, calling_service: @calling_service)

    unless @calling_notify.new_record?
      @calling_notify.called_at = Time.now
      @calling_notify.status = 'unservice'
    end

    if @calling_notify.save
      render json: { status: "ok", message: "呼叫成功", type: (params[:type] || 'nothing') }
    else
      render json: { status: "failure", error: "呼叫错误，请刷新再尝试" }
    end
  end

  def share
    cookies[:table_nu] = nil
  end

  def table_numbers
    cookies[:table_weixin_openid] = current_user.try(:weixin_openid) || get_weixin_openid_form_session

    if browser.wechat? && cookies[:table_weixin_openid].blank?
      # for weixin openid but not uboss user
      session[:oauth_callback_redirect_path] = request.fullpath
      redirect_to user_omniauth_authorize_path(:wechat)
    else
      @table_numbers = TableNumber.where(user: @seller).order("number ASC")
    end
  end

  def set_table_number
    table_number = TableNumber.find_by(user: @seller, status: 0, number: params[:number])
    old_number   = cookies[:table_nu]

    if table_number
      if old_number
        TableNumber.clear_seller_table_number(@seller, old_number)
      end

      cookies[:table_nu] = table_number.number
      table_number.update(status: "used", weixin_openid: cookies[:table_weixin_openid])
      redirect_to action: :index
    else
      flash[:error] = "请选择正确的桌号"
      redirect_to action: :table_numbers
    end
  end

  private

  def find_seller
    @seller = User.find(params[:seller_id])
  end

  def find_using_table_number
    unless @table_number = TableNumber.find_by(user: @seller, number: cookies[:table_nu], status: 1)
      redirect_to action: :table_numbers
    end
  end

end
