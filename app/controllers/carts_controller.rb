class CartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @cart = current_cart
    cart_items = @cart.cart_items
    @valid_items = CartItem.valid_items(cart_items)
    @invalid_items = cart_items - @valid_items
    render layout: 'mobile'
  end

  def delete_item
    cart_item = CartItem.find(params[:item_id])

    if current_cart.remove_product_from_cart(cart_item.product_id)
      session[:cart_item_ids].try(:delete, params[:item_id])
      render json: { status: "ok", id: params[:item_id] }
    else
      render json: { status: "failure" }
    end
  end

  def delete_all
    current_cart.remove_all_products_in_cart
    session[:cart_item_ids] = nil
  end

  def change_item_count
    cart_item = CartItem.find(params[:item_id])
    count = params[:count].to_i

    count = 1 if count <= 0
    if count > (pcount = cart_item.product.reload.count)
      count = pcount
      alert = "最多只能购买#{count}件"
    end

    if current_cart.change_cart_item_count(cart_item.product_id, count, current_cart.id)
      render json: { status: "ok", item_id: params[:item_id], count: count, alert: (alert || "") }
    else
      render json: { status: "failure", error: "数量修改失败，请刷新再尝试" }
    end
  end
end
