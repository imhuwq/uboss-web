class Api::V1::Admin::ServiceStoresController < ApiBaseController

  def create
    authorize! :create, ServiceStore
    @service_store = current_user.bulid_service_store(service_store_params)
    if @service_store.save
      render_model_id @service_store
    else
      render_model_errors @service_store
    end
  end

  def verify
    result = VerifyCode.verify(current_user, params[:code])
    if result[:success]
      render json: { message: result[:message] }
    else
      render_error :validation_failed, result[:message]
    end
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

end
