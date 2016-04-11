class DishesOrderForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  validate  :captcha_must_be_valid, :mobile_blank_with_oauth_or_binding, if: :need_bind_mobile
  validate  :product_must_be_valid

  delegate :id  , to: '@order'        , prefix: :order  , allow_nil: true
  delegate :user, to: '@sharing_node' , prefix: :sharing, allow_nil: true

  attr_accessor :sharing_node, :order, :buyer, :mobile, :captcha, :session, :seller_id

  define_model_callbacks :save

  before_save :ensure_valid!

  def ensure_valid!
    order &&
    valid? &&
    order.valid? &&
    order.order_items.all? { |i| i.errors.blank? }
  end

  def initialize(order, options={})
    @order = order
    @sharing_node = SharingNode.find_by(code: options[:sharing_code])
    options.each { |k, v| instance_variable_set("@#{k}", v) }
    set_attributes
  end

  def set_attributes
    order.user = buyer
    order.mobile = buyer.login
    order.order_items.each do |item|
      item.sharing_node = sharing_node
      item.user = buyer
    end
  end

  def save
    run_callbacks(:save) do
      order.save
    end
  end

  def order_items
    order.order_items.each &:reset_payment_info
  end

  def total_privilege_amount
    return 0 if sharing_node.blank?
    @total_privilege_amount ||= order.order_items.reduce(0) do |sum, item|
      sum + item.privilege_card.amount(item.product_inventory) * item.amount.to_i
    end
  end

  def pay_amount
    @pay_amount ||= order.order_items.map(&:pay_amount).sum - total_privilege_amount
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

  def product_must_be_valid
    order_items.each do |item|
      product_inventory = item.product_inventory
      item.errors.add(:base, "此规格商品不可售") if not product_inventory.saling?
      if item.amount > product_inventory.count
        item.errors.add(:base, "#{inventory.product.name} #{inventory.sku_attributes_str}库存不足，最多购买 #{amount} 件")
      end
    end
    errors.add(:base, "菜品必须为同一商家") if product_inventories.any? { |inventory| inventory.product.user_id.to_i != seller_id.to_i }
  end

  def product_inventories
    @product_inventories ||= ProductInventory.where(id: order_items.map {|i| i['product_inventory_id']}).includes(:product).to_a
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
