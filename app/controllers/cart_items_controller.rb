class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    product_inventory = ProductInventory.find(params[:product_inventory_id])
    sharing_code      = get_product_or_store_sharing_code(product_inventory.product)
    cart_item         = current_cart.add_product(product_inventory, sharing_code, params[:count].to_i)

    if cart_item.save
      render json: { status: 'ok', cart_items_count: current_cart.sum_items_count }
    else
      render json: { status: 'failue', message: cart_item.errors.full_messages.join('<br/>') }
    end
  end
end
