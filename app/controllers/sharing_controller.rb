# 分享链接
class SharingController < ApplicationController

	def show
		@sharing_node = SharingNode.find_by!(code: params[:code])
    set_sharing_code(@sharing_node)
    path = if @sharing_node.product_id.present?
             product_path(@sharing_node.product_id)
           else
             store_path(@sharing_node.seller_id)
           end
    redirect_to path
	end

end
