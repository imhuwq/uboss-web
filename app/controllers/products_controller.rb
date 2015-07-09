# 商品展示
class ProductsController < ApplicationController
  def index
    @products = Product.published.order('updated_at DESC').page(params[:page] || 1).per(4)
  end
  def democontent
    @products = Product.published.order('updated_at DESC').page(params[:page] || 1).per(4)
    render  :layout=>false
  end

  def show
    @product = Product.published.find(params[:id])
    if current_user
      @sharing_link_node = SharingNode.find_or_create_user_last_sharing_by_product(current_user, @product)
    end
    if @scode = get_product_sharing_code(@product.id)
      @sharing_node = SharingNode.find_by(code: @scode)
      @privilege_card = @sharing_node.privilege_card
    end
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
