class CategoriesController < ApplicationController

	layout 'mobile'

  before_action :set_store, only: [:show]

  def show
  	@categories = @store.categories
  	@category = @categories.find(params[:id])
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
  end

end
