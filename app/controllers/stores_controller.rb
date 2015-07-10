class StoresController < ApplicationController
  def show
    @seller = User.find(params[:id])
    @products = @seller.products
    render 'products/index'
  end
end
