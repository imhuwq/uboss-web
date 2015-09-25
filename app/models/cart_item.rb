class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product
  belongs_to :seller, class_name: "User"
  belongs_to :sharing_node

  validates_presence_of   :cart_id, :product_id, :seller_id
  validates_uniqueness_of :product_id, scope: :cart_id

  delegate :image_url, :name, :original_price, :present_price, to: :product

  before_save :check_count

  def self.total_price_of(id_array)
    items = CartItem.find(id_array)
    total_price = items.inject(0){ |sum, item| sum + item.real_price*item.count }
    return true, total_price
  rescue ActiveRecord::RecordNotFound
    return false, 0
  end

  # 购物车商品按店铺分组
  def self.group_by_seller(cart_items)
    seller_ids = cart_items.map(&:seller_id).uniq
    items = {}
    seller_ids.each { |seller_id| items.merge!({User.find(seller_id).identify => cart_items.select { |item| item.seller_id == seller_id }}) }
    items
  end

  def real_price
    sharing_node ? (present_price - sharing_node.privilege_amount.to_f.to_d) : present_price
  end

  private
  def check_count
    if count <= 0 || count > product.reload.count
      errors.add(:count, :invalid)
      return false
    end
  end
end
