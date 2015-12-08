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
		render json: {url: product.advertisement_img_url}.to_json
	end

	def updata_product_advertisement_img
		product = Product.find(params[:id])
		if product.update(advertisement_img: params[:avatar])
			@message = {message: "上传成功！"}
		else
			@message = {message:"上传失败"}
		end
		render json:  @message
	end

end