class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product
  belongs_to :seller, class_name: "User"
  belongs_to :sharing_node

  validates_presence_of   :cart_id, :product_id, :seller_id
  validates_uniqueness_of :product_id, scope: :cart_id

  delegate :image_url, :name, :original_price, :present_price, to: :product

  def self.total_price_of(id_array)
    items = CartItem.find(id_array)
    total_price = items.inject(0){ |sum, item| sum + item.present_price*item.count }
    return true, total_price
  rescue ActiveRecord::RecordNotFound
    return false, 0
  end
end
