class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product_inventory
  belongs_to :seller, class_name: "User"
  belongs_to :sharing_node

  validates_presence_of   :cart_id, :product_inventory_id, :seller_id
  validates_uniqueness_of :product_inventory_id, scope: :cart_id

  delegate :product_name, :price, to: :product_inventory

  before_save :check_count
  after_update :update_user_cart_sharing_info_in_one_store, if: :sharing_node_store_changed?

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
    cart_items.map{ |cart_item| cart_item if cart_item.product_inventory_valid? }.compact
  end

  def self.invaild_items(cart_items)
    cart_items - valid_items(cart_items)
  end

  def image_url
    product_inventory.image_url
  end

  def product
    product_inventory.product
  end

  def total_price
    price*count
  end

  def product_inventory_valid?
    product_inventory.published? && check_count
  end

  def check_count
    if count <= 0 || count > product_inventory.reload.count
      errors.add(:count, :invalid)
      return false
    else
      return true
    end
  end

  private

  def sharing_node_store_changed?
    if self.sharing_node_id_changed? && sharing_node.present?
      sharing_node_was = if sharing_node_id_was.present?
                           SharingNode.find(sharing_node_id_was)
                         else
                           nil
                         end
      return true if sharing_node_was.blank?
      if sharing_node_was.sharing_store_id != sharing_node.sharing_store_id
        return true
      end
      false
    end
    false
  end

  def update_user_cart_sharing_info_in_one_store
    cart.cart_items.
      where.not(id: self.id).
      where(seller_id: sharing_node.sharing_store_id).
      update_all(sharing_node_id: sharing_node.lastest_seller_sharing_node.id)
  end

end
