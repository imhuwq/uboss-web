# 商品展示
class ProductsController < ApplicationController
  def index
    @products = Product.where(status:1).order('updated_at DESC').page(params[:page] || 1).per(10)
  end

  def show
    @product = Product.where(status:1).find_by_id(params[:id])
    redirect_to action: :index if @product.blank?
  end

  def save_mobile
    mobile = params[:save_mobile][:mobile] rescue nil
    if mobile.present?
      if user = User.find_by_mobile(mobile)
        # TODO
      else
        user = User.create_guest(mobile)
      end
    end
    @product = Product.find_by_id(params[:id])
    if @product.present? && user.present?
      @sharing_node = SharingNode.create(user_id: user.id, product_id: @product.id)
    end
    respond_to do |format|
      format.html { render nothing: true }
      format.js
    end
  end
end
