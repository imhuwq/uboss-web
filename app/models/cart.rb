class Cart < ActiveRecord::Base
  has_many   :cart_items, dependent: :destroy
  belongs_to :user
  #has_many   :items, through: :cart_items, source: :product

  validates_presence_of :user_id

  def empty?
    cart_items.blank?
  end

  def add_product(product, sharing_code, count=1)
    cart_item = cart_items.find_or_initialize_by(product_id: product.id, seller_id: product.user_id)
    cart_item.sharing_node = SharingNode.find_by(code: self.sharing_code) if sharing_code
    cart_item.count += count
    cart_item
  end

  def remove_product_from_cart(product_id)
    cart_items.where(product_id: product_id).destroy_all
  end

  def remove_all_products_in_cart
    cart_items.destroy_all
  end

  def remove_cart_items(cart_item_ids)
    cart_items.where(id: cart_item_ids).destroy_all
    self.destroy if cart_items.blank?
  end

  def change_cart_item_count(product_id, count, current_cart_id)
    return false if count <= 0
    cart_item = CartItem.where("product_id = ? AND cart_id = ?", product_id, current_cart_id).take!
    cart_item.count = count
    cart_item.save
  end

  def total_price # present_price
    cart_items.inject(0){ |sum, item| sum + item.present_price*CartItem.where("product_id = ? AND cart_id = ?", item.product_id, id).take!.count }
  end

  #def total_price(price_attribute)  # "original_price", "present_price"
  #  cart_items.inject(0){ |sum, item| sum + item.send(price_attribute)*CartItem.where("product_id = ? AND cart_id = ?", item.product_id, id).take!.count }
  #end

  # 合并购物车
  #def merge_cart(cart)
  #  cart.cart_items.each { |cart_item| self.add_product(cart_item.product, cart_item.count) }
  #  self
  #end
end
