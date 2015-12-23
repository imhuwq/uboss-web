class StoresController < ApplicationController

  include SharingResource

  layout 'mobile'

  before_action :login_app, only: [:show]
  before_action :authenticate_user!, only: [:favours]
  before_action :set_seller, only: [:show, :hots, :favours]
  before_action :get_sharing_node, :set_sharing_link_node, only: [:show, :hots]

  def index
    @uboss_seller = User.first
    @stores = User.role('seller').limit(10)
    @product = Product.available.first
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

  def set_seller
    @seller = User.find(params[:id])
  end

end
