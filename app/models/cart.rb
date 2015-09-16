class Cart < ActiveRecord::Base
  has_many   :cart_items, dependent: :destroy
  belongs_to :user
  #has_many   :items, through: :cart_items, source: :product

  def add_product(product)
    cart_item = cart_items.find_by(product_id: product.id)

    if !cart_item
      cart_item = cart_items.build(product_id: product.id, seller_id: product.user_id)
    end
    cart_item.count += 1
    cart_item.save
  end

  def remove_product_from_cart(product_id)
    cart_items.where(product_id: product_id).destroy_all
  end

  def remove_all_products_in_cart
    cart_items.destroy_all
  end

  def change_cart_item_count(product_id, count, current_cart_id)
    cart_item = CartItem.where("product_id = ? AND cart_id = ?", product_id, current_cart_id).take!
    cart_item.count = count
    cart_item.save
  end

  def total_price(price_attribute)  # "original_price", "present_price"
    cart_items.inject(0){ |sum, item| sum + item.send(price_attribute)*CartItem.where("product_id = ? AND cart_id = ?", item.product_id, id).take!.count }
  end
end
