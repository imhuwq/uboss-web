# 商品展示
class ProductsController < ApplicationController

  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    render partial: 'products/product', collection: @products if request.xhr?
  end

  def show
    @product = Product.published.find_by_id(params[:id])
    @product_inventories = @product.product_inventories.where("count > ?",0)
    if @product.present? && (@product.product_inventories.collect(&:count).inject(:+) || @product.count) > 0
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
      render layout: 'mobile'
    else
      render action: :no_found, layout: 'mobile'
    end
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

end
