class Admin::ServiceStoresController < AdminController
  load_and_authorize_resource
  #TODO 替换product.present_price为实付款

  def income_detail
    @total_income = get_total_income
    @income_by_date = {}

    service_product_ids = current_user.service_product_ids
    group_date = VerifyCode.where(service_product_id: service_product_ids).group_by{ |code| code.created_at.to_date }.sort_by{|key, values| key}.reverse

    group_date.each do |key, array|
      @income_by_date[key] = [ array.size, array.map do |code|
        code.service_product.present_price
      end.sum ]
    end
  end

  def statistics
    @total_income = get_total_income

    @service_products = current_user.service_products
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
    current_user.service_products.map do |product|
      product.present_price * product.verify_codes.size
    end.sum
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
