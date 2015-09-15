# 商品展示
class ProductsController < ApplicationController

  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    render partial: 'products/product', collection: @products if request.xhr?
  end

  def show
    invoke_product_showing_info
    render layout: 'mobile'
  end

  def refact
    invoke_product_showing_info
    #render layout: 'mobile'
  end

  def save_mobile
    mobile = params[:mobile] rescue nil
    if mobile.present?
      user = User.find_or_create_guest(mobile)
    end
    @product = Product.find(params[:id])
    if @product.present? && user.present?
      @sharing_link_node = SharingNode.find_or_create_by(user_id: user.id, product_id: @product.id)
    end
    respond_to do |format|
      format.html { render nothing: true }
      format.js
    end
  end

  def add_to_cart
    @product = Product.find(params[:id])
    #消费者不能购买 库存数量为0的商品
    if @product.count > 0
      current_cart.add_product_to_cart(@product)
      flash[:notice] = "你已成功将 #{@product.title} 加入购物车"
    else
      flash[:notice] = "你的购物车内已有此物品"
    end
  end

  private

  def invoke_product_showing_info
    @product = Product.published.find(params[:id])
    @seller = @product.user
    if current_user
      @sharing_link_node ||= SharingNode.find_or_create_user_last_sharing_by_product(current_user, @product)
    end
    if @scode = get_product_sharing_code(@product.id)
      @sharing_node = SharingNode.find_by(code: @scode)
      @privilege_card = @sharing_node.try(:privilege_card)
    end
  end

end
