class SharingController < ApplicationController

  before_action :set_user, only: [:product_node, :seller_node]
  after_action :active_privilege_card, only: [:product_node, :seller_node]

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
    @product = Product.find(params.fetch(:product_id))
    if current_user.present?
      head(200)
    else
      @sharing_link_node = @user.sharing_nodes.order('id DESC').find_or_create_by(product_id: @product.id)
      render_sharing_link_node
    end
  end

  def seller_node
    @seller = User.find(params.fetch(:seller_id))
    if current_user.present?
      head(200)
    else
      @sharing_link_node = @user.sharing_nodes.order('id DESC').find_or_create_by(seller_id: @seller.id)
      render_sharing_link_node
    end
  end

  private

  def render_sharing_link_node
    if @sharing_link_node.persisted?
      render json: { sharing_link: sharing_url(@sharing_link_node) }
    else
      render json: { message: @sharing_link_node.errors.full_messages.join(',') }, status: 422
    end
  end

  def set_user
    @user = if current_user.present?
              current_user
            else
              mobile = params.fetch(:mobile)
              User.find_or_create_guest(mobile)
            end
  end

  def active_privilege_card
    seller_id = if @product.present?
                  @product.user_id
                elsif @seller.present?
                  @seller.id
                end
    PrivilegeCard.find_or_active_card(@user.id, seller_id) if seller_id.present?
  end

end
