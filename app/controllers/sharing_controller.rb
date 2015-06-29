# 分享链接
class SharingController < ApplicationController
	def show
		@sharing_node = SharingNode.find_by_code(params[:code])
    @product = @sharing_node.product
    redirect_to controller: :products, action: :index if @product.blank?
    render 'products/show'
	end
end