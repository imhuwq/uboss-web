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
    if params[:type] == 'service'
      @service_store = @seller.service_store
      @voucher_products = append_default_filter @service_store.service_products.vouchers.published, order_column: :updated_at
      @group_products = append_default_filter @service_store.service_products.groups.published, order_column: :updated_at
      render :service_store
    else
      @products = append_default_filter @seller.ordinary_products.published, order_column: :updated_at
      @hots = @seller.ordinary_products.hots.recent.limit(3)
      render_product_partial_or_page
    end
  end

  def hots
    @products = append_default_filter @seller.ordinary_products.hots, order_column: :updated_at
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
