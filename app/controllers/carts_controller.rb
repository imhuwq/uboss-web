class CartsController < ApplicationController
  before_action :authenticate_user!

  def index
    @cart = current_cart
    cart_items = @cart.cart_items
    @valid_items = CartItem.valid_items(cart_items)
    @invalid_items = cart_items - @valid_items
    session[:cart_item_ids] = @valid_items.map(&:id)
    render layout: 'mobile'
  end

  def delete_item
    cart_item = CartItem.find(params[:item_id])

    if current_cart.remove_product_from_cart(cart_item.product_id)
      session[:cart_item_ids].delete(params[:item_id])
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

    if current_cart.change_cart_item_count(cart_item.product_id, params[:count].to_i, current_cart.id)
      render json: { status: "ok", total_price: current_cart.total_price }
    else
      render json: { status: "failure" }
    end
  end

  #def items_select
    #bool, total_price = CartItem.total_price_of(params[:id_array] || [])

    #if bool
      #session[:cart_item_ids] = params[:id_array]
      #render json: { status: "ok", total_price: total_price }
    #else
      #render json: { status: "failure" }
    #end
  #end
end
