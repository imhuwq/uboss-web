class CartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @cart = current_cart
  end

  def delete_item
    cart_item = CartItem.find(params[:item_id])

    if current_cart.remove_product_from_cart(cart_item.product_id)
      render json: { status: "ok", total_price: current_cart.total_price, id: params[:item_id] }
    else
      render json: { status: "failure" }
    end
  end

  def delete_all
    current_cart.remove_all_products_in_cart
  end

  def change_item_count
    cart_item = CartItem.find(params[:item_id])

    if current_cart.change_cart_item_count(cart_item.product_id, params[:count].to_i, current_cart.id)
      render json: { status: "ok", total_price: current_cart.total_price }
    else
      render json: { status: "failure" }
    end
  end

  def items_select
    bool, total_price = CartItem.total_price_of(params[:id_array] || [])

    if bool
      render json: { status: "ok", total_price: total_price }
    else
      render json: { status: "failure" }
    end
  end

  def checkout
    @order = current_user.orders.build
    @info = @order.build_info
  end
end
