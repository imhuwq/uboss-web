class CartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @cart = current_cart
    set_cart_session(current_cart.cart_items.map(&:id))
  end

  def delete_item
    cart_item = CartItem.find(params[:item_id])

    if current_cart.remove_product_from_cart(cart_item.product_id)
      set_cart_session(current_cart.cart_items.map(&:id))
      render json: { status: "ok", total_price: current_cart.total_price, id: params[:item_id] }
    else
      render json: { status: "failure" }
    end
  end

  def delete_all
    current_cart.remove_all_products_in_cart
    set_cart_session(nil)
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
      set_cart_session(params[:id_array])
      render json: { status: "ok", total_price: total_price }
    else
      render json: { status: "failure" }
    end
  end

  def checkout
    @order = current_user.orders.build
    @info = @order.build_info
  end

  private
  def set_cart_session(cart_item_ids)
    session[:cart_item_ids] = cart_item_ids
  end

end
