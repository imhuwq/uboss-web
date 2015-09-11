class StoresController < ApplicationController

  layout 'mobile'

  def show
    @seller = User.find(params[:id])
    @products = @seller.products.published
  end
end
