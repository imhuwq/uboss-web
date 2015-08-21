# 商品展示
class ProductsController < ApplicationController
  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    render partial: 'products/product', collection: @products if request.xhr?
  end

  def show
    @product = Product.published.find(params[:id])
    @seller = @product.user
    if current_user.present?
      @sharing_link_node = SharingNode.find_or_create_user_last_sharing_by_product(current_user, @product)
    else
      flash[:notice] = "请先登录"
      redirect_to settings_account_path
    end
    if @scode = get_product_sharing_code(@product.id)
      @sharing_node = SharingNode.find_by(code: @scode)
      @privilege_card = @sharing_node.privilege_card
    end
  end
end
