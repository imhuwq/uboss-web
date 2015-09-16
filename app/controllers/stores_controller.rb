class StoresController < ApplicationController

  layout 'mobile'

  before_action :set_seller

  def show
    @products = append_default_filter @seller.products.published, order_column: :updated_at
    @hots = @seller.products.hots.recent.limit(3)
    if current_user
      @sharing_link_node ||= SharingNode.find_or_create_user_last_sharing_by_seller(current_user, @seller)
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

  def set_seller
    @seller = User.find(params[:id])
  end

end
