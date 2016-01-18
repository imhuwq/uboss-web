class Admin::ServiceStoresController < AdminController
  load_and_authorize_resource

  def income_detail
    @total_income = get_total_income
    @income_by_date = {}

    verified_codes = current_user.verified_codes.group_by{ |verify_code| verify_code.updated_at.to_date }.sort_by{ |key, values| key }.reverse
    verified_codes.each do |date, codes|
      size = codes.count
      @income_by_date[date] = [size, codes.sum(&:income) ]
    end
  end

  def statistics
    @total_income = get_total_income

    @service_products = ServiceProduct.where(user_id: current_user.id)
  end

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
  def get_total_income
    current_user.verified_codes.sum(:income)
  end

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
