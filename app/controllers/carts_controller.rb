class CartsController < ApplicationController
  before_action :authenticate_user!

  def index
    current_cart
  end

  def delete_item
    product = Product.find(params[:product_id])
    current_cart.remove_product_from_cart(product.id)
  end

  def delete_all
    current_cart.remove_all_products_in_cart
  end

  def change_item_quantity
    current_cart.change_cart_item_count(params[:product_id] ,params[:count], current_cart.id)
  end

  def checkout
    @order = current_user.orders.build
    @info = @order.build_info
  end
end
