class Admin::StoresController < AdminController
	def show
		@user = current_user
    @advertisements = Advertisement.where(user_id: @user.id, platform_advertisement: false)
	end

	def update_store_logo
		if current_user.update(store_logo: params[:avatar])
			@message = {message: "上传成功！"}
		else
			@message = {message:"上传失败"}
		end
		render json:  @message
	end


	def update_advertisement_img
		adv = Advertisement.find_by(id: params[:resource_id], user_id: current_user.id)
		if adv.update(avatar: params[:avatar])
			@message = {message: "上传成功！"}
		else
			@message = {message:"上传失败"}
		end
		render json:  @message
	end

  def get_advertisement_items
    if params[:type] == 'product'
      arr = []
      current_user.products.each do |p|
        arr += [{id: p.id, text: p.name}]
      end
      render json: {products: arr}
    elsif params[:type] == 'category'
      arr = []
      current_user.categories.each do |c|
        arr += [{id: c.id, text: c.name}]
      end
      render json: {categories: arr}
    end
  end

  def create_advertisement
    if params[:advertisement]
      @adv = Advertisement.new(params.require(:advertisement).permit(:avatar, :order_number))
      @adv.platform_advertisement = false
      @adv.user_id = current_user.id
      if params[:advertisement][:type] == 'product' && product = current_user.products.find(params[:advertisement][:id])
        @adv.product_id = product.id
      elsif params[:advertisement][:type] == 'category' && category = current_user.categories.find(params[:advertisement][:id])
        @adv.category_id = category.id
      end
      if (@adv.product_id || @adv.category_id) && @adv.save
        flash.now[:success] = '创建成功'
      else
        @adv.valid?
        flash.now[:error] = "#{@adv.errors.full_messages.join('<br/>')}"
      end
    end
    @advertisements = Advertisement.where(user_id: current_user.id, platform_advertisement: false)
  end

  def remove_advertisement_item
    adv = Advertisement.find_by(id: params[:id], user_id: current_user.id)
    if adv.destroy
      flash.now[:success] = '删除成功'
    else
      flash.now[:error] = '删除失败'
    end
    @advertisements = Advertisement.where(user_id: current_user.id, platform_advertisement: false)
    render 'create_advertisement'
  end


	def update_store_name
    duplication_name = UserInfo.find_by(store_name: params[:resource_val]) if params[:resource_val] != ''
    if (!duplication_name.present? || duplication_name.try(:user_id) == current_user.id) && current_user.update(store_name: params[:resource_val])
			@message = {success: "修改成功！"}
		else
      @message = {error:"修改失败#{duplication_name.present? ? ',此名称已经有人使用。' : ''}"}
		end
		render json:  @message
	end

	def update_store_short_description
		if current_user.update(store_short_description: params[:resource_val])
			@message = {message: "修改成功！"}
		else
			@message = {message:"修改失败"}
		end
		render json:  @message
	end

  def show_category
    @category = current_user.categories.find(params[:resource_id])
    @category.update(use_in_store: true, use_in_store_at: Time.now)
    @image = @category.image_url
    @update_image_url = "admin/categories/#{@category.id}/update_category_img"
  end

  def new_advertisement
    case params[:resource_type]
    when 'product'
      @product = current_user.products.find(params[:resource_id])
      @product.update(show_advertisement: true, show_advertisement_at: Time.now)
      @image = @product.advertisement_img_url
      @update_image_url = "admin/stores/#{@product.id}/update_product_advertisement_img"
      render 'new_advertisement_product'
    when 'category'
      @category = current_user.categories.find(params[:resource_id])
      @category.update(show_advertisement: true, show_advertisement_at: Time.now)
      @image = @category.advertisement_img_url
      @update_image_url = "admin/categories/#{@category.id}/update_category_advertisement_img"
      render 'new_advertisement_category'
    end
  end

  def remove_advertisement
    case params[:resource_type]
    when 'product'
      product = current_user.products.find(params[:resource_id])
      if product.update(show_advertisement: false)
        @message = {success:"修改成功"}
      else
        @message = {error:"修改失败"}
      end
    when 'category'
      category = current_user.categories.find(params[:resource_id])
      if category.update(show_advertisement: false)
        @message = {success:"修改成功"}
      else
        @message = {error:"修改失败"}
      end
    end
    render json: @message.to_json
  end

end

