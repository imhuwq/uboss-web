class StoresController < ApplicationController

  layout 'mobile'

  before_action :set_seller, :set_sharing_link_node, only: [:show, :hots]

  def show
    @products = append_default_filter @seller.products.published, order_column: :updated_at
    @hots = @seller.products.hots.recent.limit(3)

    if @store_scode = get_seller_sharing_code(@seller.id)
      @sharing_node = SharingNode.find_by(code: @store_scode)
    end
    render partial: 'product', collection: @products if request.xhr?
  end

  def hots
    @hide_hot_box = true
    @products = append_default_filter @seller.products.hots, order_column: :updated_at
    if request.xhr?
      render partial: 'product', collection: @products
    else
      render :show
    end
  end

  private
  def set_sharing_link_node
    if current_user.present?
      @sharing_link_node ||=
        SharingNode.find_or_create_by_resource_and_parent(current_user, @seller)
    end
  end

  def set_seller
    @seller = User.find(params[:id])
  end

end
