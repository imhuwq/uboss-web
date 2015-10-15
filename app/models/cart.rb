class Cart < ActiveRecord::Base
  has_many   :cart_items, dependent: :destroy
  belongs_to :user
  #has_many   :items, through: :cart_items, source: :product

  validates_presence_of :user_id

  def empty?
    cart_items.blank?
  end

  def add_product(product_inventory, sharing_code, count=1)
    cart_item = cart_items.find_or_initialize_by(product_inventory_id: product_inventory.id, seller_id: product_inventory.seller_id)
    cart_item.sharing_node = SharingNode.find_by(code: sharing_code) if sharing_code
    cart_item.count += count
    cart_item
  end

  def remove_product_from_cart(product_inventory_id)
    cart_items.where(product_inventory_id: product_inventory_id).destroy_all
  end

  def remove_all_products_in_cart
    cart_items.destroy_all
  end

  def remove_cart_items(cart_item_ids)
    cart_items.where(id: cart_item_ids).destroy_all
    self.destroy if cart_items.blank?
  end

  def change_cart_item_count(product_inventory_id, count, current_cart_id)
    return false if count <= 0
    cart_item = CartItem.where("product_inventory_id = ? AND cart_id = ?", product_inventory_id, current_cart_id).take!
    cart_item.count = count
    cart_item.save
  end

  def sum_items_count
    cart_items.inject(0){ |sum, item| sum + item.count }
  end

  def total_price # present_price
    CartItem.valid_items(cart_items).inject(0){ |sum, item| sum + item.total_price }
  end

  def total_price_of(cart_item_ids)
    items = CartItem.find(cart_item_ids)
    items.inject(0){ |sum, item| sum + item.total_price }
  rescue ActiveRecord::RecordNotFound
    return 0
  end

end
