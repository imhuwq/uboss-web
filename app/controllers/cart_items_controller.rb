class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    cart = current_cart
    product = Product.find(params[:product_id])
    sharing_code = get_product_sharing_code(params[:product_id])

    if cart.add_product(product, sharing_code, params[:count].to_i)
      render json: { status: 'ok', cart_items_count: cart.cart_items.count }
    else
      render json: { status: 'failue' }
    end
  end

  def destroy
    @cart_item = CartItem.find(params[:id])
    if @cart_item.destroy
      render json: {status: "ok", total_price: current_cart.total_price}
    else
      render json: {status: "failure"}
    end
  end
end
