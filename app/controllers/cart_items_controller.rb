class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    cart = current_cart
    product = Product.find(params[:product_id])
    sharing_code = get_product_sharing_code(params[:product_id])
    cart_item = cart.add_product(product, sharing_code, params[:count].to_i)

    if cart_item.save
      render json: { status: 'ok', cart_items_count: cart.cart_items.count }
    else
      render json: { status: 'failue', message: cart_item.errors.full_messages.join('<br/>') }
    end
  end

  def destroy
    @cart_item = CartItem.find(params[:id])
    if @cart_item.destroy
      render json: {status: "ok", total_price: current_cart.total_price}
    else
      render json: {status: "failure", message: @cart_item.errors.full_messages.join('<br/>') }
    end
  end
end
