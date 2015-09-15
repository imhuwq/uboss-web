class Cart < ActiveRecord::Base
  has_many   :line_items
  belongs_to :user
  has_many   :items, through: :line_items, source: :product

  def add_product_to_cart(product)
    items << product
    # cart_items和product
  end

  def remove_product_from_cart(product)
    items.destroy(product)
    #cart_items.destroy_all
    cart_items.where(product_id: product.id).destroy_all
  end

  def remove_all_products_in_cart
    items.destroy_all
    #clear => destory_all
  end

  def change_cart_item_quantity(product_id, count, current_cart_id)
    cart_item = CartItem.where("product_id = ? AND cart_id = ?", product_id, current_cart_id).take!
    cart_item.count = count
    cart_item.save
  end

  def total_price(cart_id)
    items.inject(0){ |sum, item| sum + item.present_price*CartItem.where("product_id = ? AND cart_id = ?", item.id, cart_id).take!.count }
  end
end
