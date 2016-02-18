class Admin::DashboardController < AdminController
  def index
    @unship_orders = current_user.sold_ordinary_orders.payed.includes(:user).limit(10)
    @sellers = current_user.sellers.unauthenticated_seller_identify.limit(10)
    @official_agent_product = OrdinaryProduct.official_agent
    @unship_amount = current_user.sold_ordinary_orders.payed.count
    @today_selled_amount = current_user.sold_orders.today.count
    @total_history_income = current_user.transactions.sum(:adjust_amount)
    get_expect_income
  end

  def backend_status
  end

  def initialize_user_role
    if params[:role] == 'ordinary_store_seller'
      @title = '创建普通商户'
    elsif params[:role] == 'service_store_seller'
      @title = '创建团购商户'
    else
      flash[:error] = '不存在的角色'
      redirect_to admin_root_path
      return
    end
    hash = JSON.parse RestClient.get("http://ip.taobao.com/service/getIpInfo.php?ip=#{request.remote_ip}")
    # hash = JSON.parse RestClient.get( "http://ip.taobao.com/service/getIpInfo.php?ip=218.18.3.156")
    @city = hash['data']['city_id']
    @region = hash['data']['region_id']
    @county = hash['data']['county_id']
  end

  def create_role
    if params[:role_info].present?
      case params[:role_info][:role]
      when 'ordinary_store_seller'
        if current_user.user_info.update(role_info_params)
          current_user.user_roles << UserRole.ordinary_store_seller unless current_user.is_ordinary_store_seller?
          flash[:success] = '普通店铺开启成功！'
          redirect_to action: :create_role_success_page, role: 'ordinary_store_seller'
          return
        end
      when 'service_store_seller'
        if current_user.service_store.update(role_info_params)
          current_user.user_roles << UserRole.service_store_seller unless current_user.is_service_store_seller?
          flash[:success] = '团购店铺开启成功！'
          redirect_to action: :create_role_success_page, role: 'service_store_seller'
          return
        end
      end
    end
    redirect_to action: :initialize_user_role, role: params[:role_info][:role]
  end

  def create_role_success_page
  end

  private

  def get_expect_income
    @expect_income = 0
    if current_user.is_seller?
      @expect_income += current_user.sold_ordinary_orders.shiped.sum(:pay_amount) * 0.90
    end
    if current_user.is_agent?
      @expect_income += current_user.seller_ordinary_orders.shiped.sum(:pay_amount) * 0.05
    end
  end

  def role_info_params
    params.require(:role_info).permit(:province, :city, :area, :street, :store_name, :area_code, :fixed_line, :phone_number, :begin_hour, :begin_minute, :end_hour, :end_minute)
  end
end
