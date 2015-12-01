class Admin::ServiceStoresController < AdminController
  def edit
    @service_store = ServiceStore.find(params[:id])
  end

  def update
    @service_store= ServiceStore.find(params[:id])
    if @service_store.update(service_store_params)
      flash[:success] = '更新店铺信息成功'
      redirect_to edit_admin_service_store_path(@service_store)
    else
      render :edit
    end
  end

  private
  def service_store_params
    params.require(:service_store).permit(
      :store_name, :store_short_description, :store_cover, :province, :city, :area,
      :street, :store_phones_attributes, :begin_hour, :begin_minute, :end_hour, :end_minute,
      store_phones_attributes: [
        :id, :area_code, :fixed_line, :phone_number, :_destroy
      ]
    )
  end
end
