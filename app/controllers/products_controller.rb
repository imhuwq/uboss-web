# 商品展示
class ProductsController < ApplicationController

  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    render partial: 'products/product', collection: @products if request.xhr?
  end

  def show
    @product = Product.published.find_by_id(params[:id])
    if @product.present?
      @seller = @product.user
      if qr_sharing?
        current_user && @privilege_card = current_user.privilege_cards.find_by(seller_id: @product.user_id)
      elsif @store_scode = get_seller_sharing_code(@seller.id)
        @store_node = SharingNode.find_by(code: @store_scode)
        @store_node && @product_sharing_node = @store_node.lastest_product_sharing_node(@product)
        @sharing_node = (@product_sharing_node || @store_node)
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

end
