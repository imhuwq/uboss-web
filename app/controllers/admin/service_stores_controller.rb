class Admin::ServiceStoresController < AdminController
  load_and_authorize_resource

  def remove_advertisement_item
    adv = Advertisement.find_by!(id: params[:resource_id], user_id: current_user.id, user_type: 'Service')
    if adv && adv.destroy
      flash.now[:success] = '删除成功'
    else
      flash.now[:error] = '删除失败'
    end
    @advertisements = get_advertisements
    render 'create_advertisement'
  end

  def update_advertisement_img
    adv = Advertisement.find_by!(id: params[:resource_id], user_id: current_user.id, user_type: 'Service')
    if adv && adv.update(avatar: params[:avatar])
      @message = { message: '上传成功！' }
    else
      @message = { message: '上传失败' }
    end
    render json:  @message
  end

  def income_detail
    @total_income = get_total_income
    @income_by_date = {}

    verified_codes = current_user.verify_codes.group_by{ |verify_code| verify_code.updated_at.to_date }.sort_by{ |key, values| key }.reverse
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
    @advertisements = get_advertisements
  end

  def update
    if @service_store.update(service_store_params)
      flash[:success] = '更新店铺信息成功'
      redirect_to edit_admin_service_store_path(@service_store)
    else
      @advertisements = get_advertisements
      render :edit
    end
  end

  def create_advertisement
    if params[:advertisement]
      adv = Advertisement.new(params.require(:advertisement).permit(:avatar))
      adv.platform_advertisement = false
      adv.user_id = current_user.id
      adv.user_type = 'Service'
      if !adv.save
        flash[:error] = '图片保存失败'
      end
    end
    @advertisements = get_advertisements
  end

  private
  def get_advertisements
    Advertisement.where(user_type: 'Service', user_id: current_user.id).order('order_number')
  end

  def get_total_income
    current_user.verify_codes.sum(:income)
  end

  def service_store_params
    params.require(:service_store).permit(
      :store_name, :store_short_description, :store_cover, :province, :city, :area,
      :street, :begin_hour, :begin_minute, :end_hour, :end_minute,
      store_phones_attributes: [
        :id, :area_code, :fixed_line, :phone_number, :_destroy
      ]
    )
  end
end
