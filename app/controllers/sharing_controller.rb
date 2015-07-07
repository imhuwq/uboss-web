# 分享链接
class SharingController < ApplicationController
	def show
		@sharing_node = SharingNode.find_by!(code: params[:code])
    set_product_sharing_code(@sharing_node.product_id, params[:code])
    redirect_to product_path(@sharing_node.product_id)
	end
end
