class Admin::BusinessesController < AdminController

  def index
  end

  def new
    if params[:role] == 'ordinary_store_seller'
      @title = '创建普通商户'
      @store = current_user.ordinary_store
    elsif params[:role] == 'service_store_seller'
      @title = '创建团购商户'
      @store = current_user.service_store
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

  def create
    if params[:role_info].present?
      case params[:role_info][:role]
      when 'ordinary_store_seller'
        if current_user.user_info.update(role_info_params)
          current_user.user_roles << UserRole.ordinary_store_seller unless current_user.is_ordinary_store_seller?
          flash[:success] = '普通店铺开启成功！'
          redirect_to action: :success_page, role: 'ordinary_store_seller'
          return
        end
      when 'service_store_seller'
        if current_user.service_store.update(role_info_params)
          current_user.user_roles << UserRole.service_store_seller unless current_user.is_service_store_seller?
          flash[:success] = '团购店铺开启成功！'
          redirect_to action: :success_page, role: 'service_store_seller'
          return
        end
      end
    end
    redirect_to action: :new, role: params[:role_info][:role]
  end

  def success_page
  end

  private

  def role_info_params
    params.require(:role_info).permit(:province, :city, :area, :street, :store_name, :begin_hour, :begin_minute, :end_hour, :end_minute, :store_phones_attributes, store_phones_attributes: [
        :area_code, :fixed_line, :phone_number
      ])
  end

end
