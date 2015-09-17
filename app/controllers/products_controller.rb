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

  # TODO remove old show page
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
    @product = Product.published.find(params[:id])
    @seller = @product.user
    if @store_scode = get_seller_sharing_code(@seller.id)
      sharing_node = SharingNode.find_by(code: @store_scode)
      product_sharing_node = sharing_node.lastest_product_sharing_node(@product)
      @sharing_node = (product_sharing_node || sharing_node)
      @privilege_card = @sharing_node.try(:privilege_card)
    elsif @scode = get_product_sharing_code(@product.id)
      @sharing_node = SharingNode.find_by(code: @scode)
      @privilege_card = @sharing_node.try(:privilege_card)
    end
    if current_user
      @sharing_link_node ||=
        SharingNode.find_or_create_by_resource_and_parent(current_user, @product, @sharing_node)
    end
  end

end
