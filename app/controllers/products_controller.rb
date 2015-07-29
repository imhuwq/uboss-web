# 商品展示
class ProductsController < ApplicationController

  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    if request.xhr?
      render partial: 'products/product', collection: @products
    end
  end

  def show
    @product = Product.published.find(params[:id])
    @seller = @product.user
    if current_user
      @sharing_link_node = SharingNode.find_or_create_user_last_sharing_by_product(current_user, @product)
    end
    if @scode = get_product_sharing_code(@product.id)
      @sharing_node = SharingNode.find_by(code: @scode)
      @privilege_card = @sharing_node.privilege_card
    end
  end

  def save_mobile
    mobile = params[:mobile] rescue nil
    @job = params[:job]
    puts "@job=#{@job}"
    if mobile.present?
      user = User.find_by_mobile(mobile)
      if user.present?
        # TODO
      else
        user = User.create_guest(mobile)
      end
    end
    @product = Product.find_by_id(params[:id])
    if @product.present? && user.present?
      @sharing_link_node = SharingNode.find_or_create_by(user_id: user.id, product_id: @product.id)
    end
    respond_to do |format|
      format.html { render nothing: true }
      format.js
    end
  end
end
