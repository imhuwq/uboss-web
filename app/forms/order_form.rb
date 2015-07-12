class OrderForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Model

  ATTRIBUTES = [
    :product_id, :amount, :mobile, :captcha, :user_address_id, :deliver_username,
    :province, :city, :country, :area, :building, :street, :deliver_mobile, :sharing_code
  ]

  ATTRIBUTES.each do |order_attr|
    attr_accessor order_attr
  end

  attr_accessor :sharing_node, :product, :buyer, :user_address, :order

  validates :product_id, :amount, presence: true
  validates :mobile, presence: true, mobile: true, if: :need_mobile?
  validates :deliver_mobile, :deliver_username, :street, presence: true, if: -> { self.user_address_id.blank? }
  validates :deliver_mobile, mobile: true, allow_blank: true
  validate :captcha_must_be_valid, if: :need_verify_captcha?
  validate :check_amount

  delegate :traffic_expense, to: :product, prefix: :product

  def user_address
    return @user_address if @user_address.present?
    if buyer && user_address_id.present?
      @user_address = buyer.user_addresses.find(self.user_address_id)
    end
  end

  def product
    @product ||= Product.find(self.product_id)
  end

  def sharing_node
    @sharing_node ||= SharingNode.find_by(code: self.sharing_code)
  end

  def real_price
    if sharing_node.present?
      product.present_price.to_f - sharing_node.privilege_amount.to_f
    else
      product.present_price.to_f
    end
  end

  def save
    # - verify Mobile captcha
    # - check product valid?
    # - check SKU amount
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
    if buyer.present? || (self.buyer = User.find_by(login: mobile))
      set_user_login
    else
      self.buyer = User.create_guest!(mobile)
    end
  end

  def set_user_login
    if buyer.need_set_login?
      buyer.update_columns(login: mobile, need_set_login: false)
    end
  end

  def create_user_address
    return true if user_address.present?

    self.user_address = UserAddress.create!(
      user: buyer,
      mobile: deliver_mobile,
      username: deliver_username,
      country: country,
      province: province,
      city: city,
      area: area,
      street: street,
      building: building
    )
  end

  def create_order_and_order_item
    self.order = Order.create!(
      user: buyer,
      seller: product.user,
      user_address: self.user_address,
      order_items_attributes: order_items_attributes)
  end

  def order_items_attributes
    @order_items ||= [{
      product: product,
      user: buyer,
      amount: amount,
      sharing_node: sharing_node
    }]
  end

  def check_amount
    if amount.to_i > product.reload.count
      errors.add(:amount, '库存不足')
    end
  end

  def need_mobile?
    buyer.blank? ? true : buyer.need_set_login?
  end

  def need_verify_captcha?
    buyer.blank? ? mobile.present? : buyer.need_set_login?
  end

  def captcha_must_be_valid
    if !MobileAuthCode.auth_code(mobile, captcha)
      errors.add(:captcha, '手机验证码错误')
    elsif buyer.present? && User.find_by(login: mobile)
      errors.add(:mobile, '该手机号码已绑定账号')
    end
  end

end
