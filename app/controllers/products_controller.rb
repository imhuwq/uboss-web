# 商品展示
class ProductsController < ApplicationController

  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    render partial: 'products/product', collection: @products if request.xhr?
  end

  def show
    invoke_product_showing_info
    unless @product.present?
      redirect_to action: :no_found
      return
    end
    render layout: 'mobile'
  end

  def no_found
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

  private

  def invoke_product_showing_info
    @product = Product.published.find_by_id(params[:id])
    if @product.present?
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

end
