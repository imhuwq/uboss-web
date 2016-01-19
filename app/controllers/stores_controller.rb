class StoresController < ApplicationController
  include SharingResource

  layout 'mobile'

  before_action :login_app, only: [:show]
  before_action :authenticate_user!, only: [:favours]
  before_action :set_seller, only: [:show, :hots, :favours]
  before_action :get_sharing_node, :set_sharing_link_node, only: [:show, :hots]

  def index
    @uboss_seller = User.find_by(login: '19812345678')
    @recommend_ids = @uboss_seller.store_short_description.split(',')
    @stores = User.where(id: @recommend_ids)
  end

  def show
    if params[:order] == 'published_at'
      @order_column_name = 'published_at'
      @products = append_default_filter @seller.products.published.includes(:asset_img), order_column: :published_at, order_type: 'DESC', page_size: 6, column_type: :datetime
    elsif  params[:order] == 'sales_amount_order'
      @order_column_name = 'sales_amount_order'
      @products = append_default_filter @seller.products.published.includes(:asset_img), order_column: :sales_amount_order, order_type: 'ASC', page_size: 6, column_type: :integer
    else
      @order_column_name = 'comprehensive_order'
      @products = append_default_filter @seller.products.published.includes(:asset_img), order_column: :comprehensive_order, order_type: 'ASC', page_size: 6, column_type: :integer
    end
    @hots = @seller.products.hots.recent.limit(3)
    @categories = Category.where(use_in_store: true, user_id: @seller.id).order('use_in_store_at')
    render_product_partial_or_page
  end

  def hots
    @products = append_default_filter @seller.products.hots.includes(:asset_img), order_column: :updated_at
    render_product_partial_or_page
  end

  def favours
    @order_column_name = 'updated_at'
    @products = append_default_filter current_user.favoured_products.where(user_id: @seller.id).includes(:asset_img)
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
