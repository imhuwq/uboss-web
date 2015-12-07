class Admin::StoresController < AdminController
	def show
		@user = current_user
	end

	def update_strore_logo
		if current_user.update(store_logo: params[:avatar])
			@message = {message: "上传成功！"}
		else
			@message = {message:"上传失败"}
		end
		render json:  @message
	end
end