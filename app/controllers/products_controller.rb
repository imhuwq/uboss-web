# 商品展示
class ProductsController < ApplicationController

  before_action :set_product, only: [:switch_favour]

  def index
    @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
    render partial: 'products/product', collection: @products if request.xhr?
  end

  def show
    @product = Product.published.find_by_id(params[:id])
    return render_product_invalid if @product.blank?

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
  end

  def get_sku
    # binding.pry
    product = Product.find(params[:product_id])
    # skus = {}
    # sku_details = {}
    # product.product_inventories.where("count > 0").each do |obj|
    #   obj.sku_attributes.each do |k,v|
    #     if !skus[k].present?
    #       skus[k] = {}
    #     end
    #     if !skus[k][v].present?
    #       skus[k][v] = []
    #     end
    #     skus[k][v] << obj.id
    #   end
    #
    #   if !sku_details[obj.id].present?
    #     sku_details[obj.id] = {}
    #   end
    #   sku_details[obj.id][:count] = obj.count
    #   sku_details[obj.id][:sku_attributes] = obj.sku_attributes
    #   sku_details[obj.id][:price] = obj.price
    # end
    # hash = {}
    # hash[:skus] = skus
    # hash[:sku_details] = sku_details

    render json: product.sku_hash
    # render json: {'颜色':{'红': [1,2],'白': [3,4],'黄': [3]},'尺寸':{'L':[1,3],'XL':[2,4]}}
  end

  # FIXME 这个action没有被用到
  def get_sku_detail
    # binding.pry
    product = Product.find(params[:product_id])
    hash = {}
    product.product_inventories.where("count > 0").each do |obj|
      if !hash[obj.id].present?
        hash[obj.id] = {}
      end
      hash[obj.id][:count] = obj.count
      hash[obj.id][:sku_attributes] = obj.sku_attributes
      hash[obj.id][:price] = obj.price
    end
    render json: hash
    # render json: { '1': {count: 100, sku_attributes: {'颜色': '红', '尺寸': 'XL'},price: "1111"}, '2': {count: 50, sku_attributes: {'颜色': '白', '尺寸': 'L'},price: "1111"} }
  end

  def switch_favour
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
  def set_product
    @product ||= Product.published.find(params[:id])
  end

  def render_product_invalid
    render action: :no_found, layout: 'mobile'
  end

end
