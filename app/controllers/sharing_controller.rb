# 分享链接
class SharingController < ApplicationController
	def show
		@sharing_node = SharingNode.find_by!(code: params[:code])
    flash[:sharing_code] = params[:code]
    redirect_to product_path(@@sharing_node.product_id)
	end
end
