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

  def product_node
    mobile = params.fetch(:mobile)
    @user = User.find_or_create_guest(mobile)
    @product = Product.find(params.fetch(:product_id))
    @sharing_link_node = @user.sharing_nodes.order('id DESC').find_or_create_by(product_id: @product.id)
    if @sharing_link_node.persisted?
      render json: { sharing_link: sharing_url(@sharing_link_node) }
    else
      render json: { message: @sharing_link_node.errors.full_messages.join(',') }, status: 422
    end
  end

end
