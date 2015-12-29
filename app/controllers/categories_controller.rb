class CategoriesController < ApplicationController

  include SharingResource

	layout 'mobile'

  before_action :set_store, :get_sharing_node, :set_sharing_link_node, only: [:show]

  def show
    @categories = Category.where(use_in_store: true, user_id: @seller.id).order('use_in_store_at').where('id <> ?', params[:id])
    @category = @store.categories.find(params[:id])
  	@products = append_default_filter @category.products.published.includes(:asset_img), order_column: :updated_at, page_size: 10
    if request.xhr?
      render partial: 'stores/product', collection: @products
    else
      render :show
    end
  end

  private

  def set_store
  	@store = User.find(params[:store_id])
    @seller = @store
  end

end
