class DishesOrderForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Model

  ATTRIBUTES = [:mobile, :seller_id, :sharing_code]

  ATTRIBUTES.each do |order_attr|
    attr_accessor order_attr
  end

  attr_accessor :session, :sharing_node, :buyer, :order, :order_items_attributes

  validate  :captcha_must_be_valid, :mobile_blank_with_oauth_or_binding, if: :need_bind_mobile
  validate  :product_must_be_valid

  def product_inventory
    @product_inventory ||= ProductInventory.find(self.product_inventory_id)
  end

  def sharing_node
    return @sharing_node if @sharing_node.present?
    @sharing_node = SharingNode.find_by(code: self.sharing_code)
    if @sharing_node && @sharing_node.seller_id.present?
      @sharing_node = @sharing_node.lastest_product_sharing_node(self.product)
    end
    @sharing_node
  end

  def sharing_user
    @sharing_user ||= sharing_node.try(:user)
  end

  def save
    if self.valid?
      ActiveRecord::Base.transaction do
        create_or_update_user
        create_order_and_order_item
      end
      true
    else
      false
    end
  end

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

  def create_order_and_order_item
    self.order =
      DishesOrder.create!({
        user: buyer,
        seller_id: seller_id,
        mobile: buyer.login,
        order_items_attributes: order_items_attributes
        })
  end

  def order_items_attributes=(items)
    @order_items_attributes = items.map do |_, item|
      item[:sharing_node] = sharing_node if sharing_node
      item[:user_id]      = buyer.id
      item
    end
  end

  def product_must_be_valid
    errors.add(:base, "菜品必须为同一商家") if product_inventories.any? { |inventory| inventory.product.user_id.to_i != seller_id.to_i }
    product_inventories.detect do |inventory|
      item_attr = order_items_attributes.detect {|item| item["product_inventory_id"].to_i == inventory.id }
      if !inventory.saling?
        errors.add(:base, "该商品不可售")
      elsif item_attr["amount"].to_i > inventory.reload.count
        self.amount = inventory.count
        errors.add(:base, "#{inventory.product.name} #{inventory.sku_attributes_str}库存不足，最多购买 #{amount} 件")
      end
    end
  end

  def product_inventories
    @product_inventories ||= ProductInventory.where(id: order_items_attributes.map {|i| i['product_inventory_id']}).includes(:product).to_a
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
