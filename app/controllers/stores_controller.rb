class StoresController < ApplicationController

  layout 'mobile'

  before_action :login_app, only: [:show]
  before_action :authenticate_user!, only: [:favours]
  before_action :set_seller, only: [:show, :hots, :favours]
  before_action :get_sharing_node, :set_sharing_link_node, only: [:show, :hots]

  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    @hot_products = []
    @products.each do |product|
      if @hot_products.empty?
        @hot_products << product
      end
      product.total_sells
    end
  end

  def show
    @products = append_default_filter @seller.products.published, order_column: :updated_at
    @hots = @seller.products.hots.recent.limit(3)
    render_product_partial_or_page
  end

  def hots
    @products = append_default_filter @seller.products.hots, order_column: :updated_at
    render_product_partial_or_page
  end

  def favours
    @products = append_default_filter current_user.favoured_products.where(user_id: @seller.id)
    render_product_partial_or_page
  end

  private

  def render_product_partial_or_page
    if request.xhr?
      render partial: 'product', collection: @products
    else
      render :show
    end
  end

  def get_sharing_node
    if @store_scode = get_seller_sharing_code(@seller.id)
      @sharing_node = SharingNode.find_by(code: @store_scode)
    end
  end

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
