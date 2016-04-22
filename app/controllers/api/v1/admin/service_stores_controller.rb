class Api::V1::Admin::ServiceStoresController < ApiBaseController

  before_action :set_service_store, only: [:show, :update, :get_id]

  def create
    authorize! :create, ServiceStore
    @service_store = current_user.bulid_service_store(service_store_params)
    if @service_store.save
      render json: { data: @service_store }
    else
      render_model_errors @service_store
    end
  end

  def verify
    authorize! :manage, VerifyCode
    result = VerifyCode.verify(current_user, params[:code])
    if result[:success]
      render json: { data: { message: result[:message] } }
    else
      render_error :validation_failed, result[:message]
    end
  end

  def show 
    authorize! :read, @store
    qrcode_url = request_qrcode_url({ text: service_store_url(id: @store.id, shared: true) })
    store_phones = @store.store_phones.select(:id, :area_code, :fixed_line, :phone_number)
    store_banners = Advertisement.where(user_type: 'Service', user_id: current_user.id).order('order_number').select(:id, :advertisement_url)
    render json: {
      data: {
        store_name: @store.store_name,
        store_short_description: @store.store_short_description,
        store_cover: @store.store_cover,
        province: @store.province,
        city: @store.city,
        area: @store.area,
        street: @store.street,
        address: @store.address,
        begin_hour: @store.begin_hour,
        begin_minute: @store.begin_minute,
        end_hour: @store.end_hour,
        end_minute: @store.end_minute,
        qrcode_url: qrcode_url,
        store_phones: store_phones,
        store_banners: store_banners
      }
    }
  end

  def update
    authorize! :update, @store
    if @store.update(service_store_params)
      render json: { data: { id: @store.id } }
    else
      render_model_errors @store
    end
  end

  def create_advertisement
    authorize! :create, Advertisement
    adv = Advertisement.new(params.permit(:avatar))
    adv.platform_advertisement = false
    adv.user_id = current_user.id
    adv.user_type = 'Service'
    if adv.save
      render json: { data: { id: adv.id } }
    else
      render_model_errors adv
    end
  end

  def remove_advertisement
    authorize! :destroy, Advertisement
    adv = Advertisement.find_by(id: params[:id], user_id: current_user.id, user_type: 'Service')
    if adv && adv.destroy
      render json: { data: {} }
    else
      render_model_errors adv
    end
  end

  def update_advertisement
    authorize! :update, Advertisement
    adv = Advertisement.find_by(id: params[:id], user_id: current_user.id, user_type: 'Service')
    if adv && adv.update(avatar: params[:avatar])
      render json: { data: { id: adv.id } }
    else
      render_model_errors adv
    end
  end

  def get_id
    authorize! :read, @store
    render json: { service_store_id: @store.id }
  end

  private
  def service_store_params
    params.permit(
      :store_name, :store_short_description, :store_cover,
      :province, :city, :area, :street, :begin_hour,
      :begin_minute, :end_hour, :end_minute,
      store_phones_attributes: [
        :id, :area_code, :fixed_line, :phone_number, :_destroy
      ]
    )
  end

  def set_service_store
    @store = current_user.service_store
  end

end
