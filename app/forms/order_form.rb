class OrderForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Model

  ATTRIBUTES = [
    :mobile, :captcha, :product_id, :product_inventory_id, :amount, :cart_id,
    :user_address_id, :deliver_username, :province, :city, :area, :building, :deliver_mobile
  ]

  ATTRIBUTES.each do |order_attr|
    attr_accessor order_attr
  end

  attr_accessor :sharing_code, :seller_ids, :cart_item_ids, :to_seller, :session,
    :sharing_node, :product, :product_inventory, :buyer, :user_address, :order

  #validates :amount, presence: true, if: -> { self.product_id }
  validates :mobile, presence: true, mobile: true, if: :need_bind_mobile
  validates :deliver_mobile, :deliver_username, :province, :city, :area, presence: true, if: -> { self.user_address_id.blank? }
  validates :deliver_mobile, mobile: true, allow_blank: true
  validates :seller_ids, :cart_item_ids, presence: true, if: -> { self.product_id.blank? }
  validate  :captcha_must_be_valid, :mobile_blank_with_oauth_or_binding, if: :need_bind_mobile
  validate  :product_must_be_valid

  def user_address
    return @user_address if @user_address.present?
    if buyer && user_address_id.present?
      @user_address = buyer.user_addresses.find(user_address_id)
    else
      @user_address = UserAddress.new(
        user: buyer,
        mobile: deliver_mobile,
        username: deliver_username,
        province: province,
        city: city,
        area: area,
        building: building
      )
    end
  end

  def product
    @product ||= Product.find(self.product_id)
  end

  def product_inventory
    @product_inventory ||= ProductInventory.find(self.product_inventory_id)
  end

  def cart_items
    @cart_itmes ||= CartItem.includes(:sharing_node, product_inventory: [:product]).find(cart_item_ids)
  end

  def sharing_node
    return @sharing_node if @sharing_node.present?
    @sharing_node = SharingNode.find_by(code: self.sharing_code)
    if @sharing_node && @sharing_node.seller_id.present?
      @sharing_node = @sharing_node.lastest_product_sharing_node(self.product)
    end
    @sharing_node
  end

  def save
    if self.valid?
      ActiveRecord::Base.transaction do
        create_or_update_user
        create_user_address
        create_order_and_order_item
      end
      true
    else
      false
    end
  end

  private

  def create_or_update_user
    self.buyer ||= User.find_by(login: mobile)
    if need_update_oauth_info?
      buyer.update_with_wechat_oauth(session['devise.wechat_data'].extra['raw_info'])
    end
    if buyer.present?
      buyer.update_columns(login: mobile, need_set_login: false) if need_bind_mobile
    end
    if buyer.blank?
      self.buyer = User.new_with_session(
        {
          login: mobile,
          password: Devise.friendly_token,
          need_reset_password: true
        },
        session
      )
      self.buyer.save!
    end
  end

  def need_update_oauth_info?
    buyer.present? && session['devise.wechat_data'] && session['devise.wechat_data'].extra['raw_info']
  end

  def create_user_address
    if user_address_id.blank? && user_address.new_record?
      user_address.user ||= self.buyer
      user_address.save!
    end
  end

  def create_order_and_order_item
    self.order =
      if product_id.present?
        OrdinaryOrder.create!([{
          user: buyer,
          seller: product.user,
          to_seller: to_seller["#{product.user_id}"],
          user_address: self.user_address,
          order_items_attributes: order_items_attributes,
          type: to_order_type(product.type),
          supplier_id: product.parent.try(:user_id)
        }])
      elsif seller_ids
        OrdinaryOrder.create!(
          orders_split_by_seller
        )
      end
  end

  def to_order_type(name)
    case name
    when "ServiceProduct"   then "ServiceOrder"
    when "OrdinaryProduct"  then "OrdinaryOrder"
    when "AgencyProduct"    then "AgencyOrder"
    else name end
  end

  def order_items_attributes
    @order_items ||= [{
      product: product,
      product_inventory: product_inventory,
      user: buyer,
      amount: amount,
      sharing_node: sharing_node
    }]
  end

  def orders_split_by_seller
    orders_attributes = []
    seller_ids.each do |seller_id|
      orders_attributes << {
        user: buyer,
        seller_id: seller_id,
        to_seller: to_seller["#{seller_id}"],
        user_address: self.user_address,
        order_items_attributes: order_items_of_seller(seller_id)
      }
    end
    orders_split_by_product_type(orders_attributes)
  end

  # 根据 order_items 的商品类型拆分
  def orders_split_by_product_type(orders_attributes)
    _orders = []
    orders_attributes.tap do |orders|
      orders.each do |order|
        next if order[:order_items_attributes].length < 2
        order[:order_items_attributes].group_by do |attrs|
          product = Product.find(attrs[:product_id])
          product.type
        end.to_a.each do |type, groups|
          _order = order.dup
          _order[:type] = to_order_type(type)
          _order[:order_items_attributes] = groups
          _orders << _order
        end
        orders.delete(order)
      end
    end
    orders_attributes.concat _orders
    orders_split_by_supplier(orders_attributes)
  end

  def orders_split_by_supplier(order_attributes)
    _orders = []
    order_attributes.tap do |orders|
      orders.each do |order|
        next if order[:order_items_attributes].length < 2
        order[:order_items_attributes].group_by do |item|
          if product = AgencyProduct.includes(:parent).find_by_id(item[:product_id])
            product.parent.user_id
          else
            nil
          end
        end.each do |supplier_id, groups|
          _order = order.dup
          _order[:supplier_id] = supplier_id
          _order[:order_items_attributes] = groups
          _orders << _order
        end
      end
      orders.delete(order)
    end
    order_attributes.concat _orders
  end

  def order_items_of_seller(seller_id)
    items = cart_items.select { |item| item.seller_id == seller_id }

    return items.collect { |item| {
      product_id: item.product_inventory.product_id,
      product_inventory_id: item.product_inventory_id,
      user: buyer,
      amount: item.count,
      sharing_node: item.sharing_node
    }}
  end

  def product_must_be_valid
    if product_id.present?
      if !product_inventory.saling?
        errors.add(:base, "该商品不可售")
      elsif !OrdinaryOrder.valid_to_sales?(product, ChinaCity.get(user_address.try(:province) || province))
        errors.add(:base, "该商品在收货地址内不可售，请重新选择收货地址")
      elsif amount.to_i > product_inventory.reload.count
        self.amount = product_inventory.count
        errors.add(:base, "该商品库存不足，最多购买 #{amount} 件")
      elsif amount.to_i > 1 && product.is_official_agent?
        self.amount = 1
        errors.add(:base, '创客权只能购买一个')
      end
    elsif seller_ids.present?
      cart_items.each do |cart_item|
        if !cart_item.product_inventory.saling?
          errors.add(:base, "#{cart_item.product_name}[#{cart_item.sku_attributes_str}] 不可售")
        elsif !OrdinaryOrder.valid_to_sales?(cart_item.product, ChinaCity.get(user_address.try(:province) || province))
          errors.add(:base, "#{cart_item.product_name} 在收货地址内不可售，请重新选择收货地址") && return
        elsif cart_item.count > cart_item.product_inventory.reload.count
          cart_item.update_attribute(:count, cart_item.product_amount)
          errors.add(:base, "#{cart_item.product_name}[#{cart_item.sku_attributes_str}] 库存不足，最多购买 #{cart_item.product_amount} 件")
        elsif cart_item.product_inventory.is_official_agent? && cart_item.count > 1
          cart_item.update_attribute(:count, 1)
          errors.add(:base, '创客权只能购买一个')
        end
      end
    end
  end

  def captcha_must_be_valid
    if !MobileCaptcha.auth_code(mobile, captcha)
      errors.add(:captcha, :invalid)
    end
  end

  def mobile_blank_with_oauth_or_binding
    user = User.find_by(login: mobile)
    return true if user.blank?
    if self.buyer.present? && need_bind_mobile
      errors.add(:mobile, '已注册UBOSS账户，您可以用此手机号登录购买')
    end
    if user.weixin_openid.present? && session['devise.wechat_data'] &&
        session['devise.wechat_data'].extra['raw_info']['weixin_openid'] != user.weixin_openid
      errors.add(:mobile, '已绑定微信账号')
    end
  end

  def need_bind_mobile
    self.buyer.blank? || (self.buyer.present? && self.buyer.need_set_login && self.buyer.login.blank?)
  end

end
