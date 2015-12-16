class Admin::StoresController < AdminController
	def show
		@user = current_user
	end

	def update_store_logo
		if current_user.update(store_logo: params[:avatar])
			@message = {message: "上传成功！"}
		else
			@message = {message:"上传失败"}
		end
		render json:  @message
	end

	def show_product_advertisement_img
		product = current_user.products.find(params[:id])
		hash = {url: product.advertisement_img_url}
		if product.show_advertisement
			hash[:show_advertisement] = true
		else
			hash[:show_advertisement] = false
		end
		render json: hash.to_json
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

	def add_to_advertisement
		product = Product.find(params[:id])
		hash= {}
		if product.show_advertisement
			product.update(show_advertisement: false)
			hash[:show_advertisement] = false
		else
			product.update(show_advertisement: true)
			hash[:show_advertisement] = true
		end
		render json:  hash.to_json
	end

end