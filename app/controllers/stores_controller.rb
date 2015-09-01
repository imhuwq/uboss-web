class StoresController < ApplicationController
  def show
    @seller = User.find(params[:id])
    @products = @seller.products.published
    render 'products/index'
  end
end
