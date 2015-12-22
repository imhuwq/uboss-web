class Admin::StoresController < AdminController
	def show
		@user = current_user
    @advertisement_products = @user.products
	end

	def update_store_logo
		if current_user.update(store_logo: params[:avatar])
			@message = {message: "上传成功！"}
		else
			@message = {message:"上传失败"}
		end
		render json:  @message
	end


	def update_product_advertisement_img
		product = Product.find(params[:resource_id])
		if product.update(advertisement_img: params[:avatar])
			@message = {message: "上传成功！"}
		else
			@message = {message:"上传失败"}
		end
		render json:  @message
	end


	# def add_to_advertisement
	# 	product = Product.find(params[:id])
	# 	hash= {}
	# 	if product.show_advertisement
	# 		product.update(show_advertisement: false)
	# 		hash[:show_advertisement] = false
	# 	else
	# 		product.update(show_advertisement: true)
	# 		hash[:show_advertisement] = true
	# 	end
	# 	render json:  hash.to_json
	# end

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

