# 商品展示
class ServiceProductsController < ApplicationController

  def index
    @products = append_default_filter ServiceProduct.published.includes(:asset_img), order_column: :updated_at
    if request.xhr?
      render partial: 'service_products/product', collection: @products
    else
      render layout: 'mobile'
    end
  end

  def show
    @product = ServiceProduct.published.find_by(id: params[:id])
    return render_product_invalid if @product.blank?

    @seller = @product.user
    @service_store = @seller.service_store
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
      @privilege_card ||= current_user.privilege_cards.find_by(seller: @seller)
      @sharing_link_node ||= SharingNode.find_or_create_by_resource_and_parent(current_user, @product, @sharing_node)
    end
    render layout: 'mobile'
  end

  def switch_favour
    @product ||= ServiceProduct.published.find(params[:id])

    if current_user.favour_products.exists?(product_id: @product.id)
      current_user.unfavour_product(@product)
      render json: { favoured: false }
    else
      @favour_product = current_user.favour_product(@product)
      if @favour_product.persisted?
        render json: { favoured: true }
      else
        render json: { favoured: false, msg: model_errors(@favour_product) }, status: 422
      end
    end
  end

  private

  def render_product_invalid
    render action: :no_found, layout: 'mobile'
  end

end
