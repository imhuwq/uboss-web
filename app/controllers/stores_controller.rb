class StoresController < ApplicationController

  layout 'mobile'

  def show
    @seller = User.find(params[:id])
    @products = append_default_filter @seller.products.published
    @hots = @seller.products.hots.recent.limit(3)
    #render partial: 'products/product', collection: @products if request.xhr?
  end

end
