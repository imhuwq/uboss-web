class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product
  belongs_to :seller, class_name: "User"
  belongs_to :sharing_node

  validates_presence_of   :cart_id, :product_id, :seller_id
  validates_uniqueness_of :product_id, scope: :cart_id

  delegate :image_url, :name, :original_price, :present_price, to: :product

  before_save :check_count

  # 购物车商品按店铺分组 TODO 什么情况下商品失效，下架、数量不正确 and ?
  def self.group_by_seller(cart_items)
    seller_ids = cart_items.map(&:seller_id).uniq
    seller_ids.inject({}) { |items, seller_id|
      items.merge!(
        { User.find(seller_id) => cart_items.select { |item| item.seller_id == seller_id } }
      )
    }
  end

  def self.valid_items(cart_items)
    cart_items.map{ |cart_item| cart_item if cart_item.product_valid? }.compact
  end

  def self.invaild_items(cart_items)
    cart_items - valid_items(cart_items)
  end

  def total_price
    present_price*count
  end

  def product_valid?
    product.published? && check_count
  end

  private
  def check_count
    if count <= 0 || count > product.reload.count
      errors.add(:count, :invalid)
      return false
    else
      return true
    end
  end

end
