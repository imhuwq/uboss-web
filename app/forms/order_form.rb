class OrderForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Model

  attr_accessor :product, :product_id, :amount, :mobile, :captcha, :buyer, :user_address, :user_address_id,
                :deliver_username, :province, :city, :country, :street, :deliver_mobile,
                :order

  validates :product_id, presence: true
  validates :mobile, presence: true, if: :need_mobile?
  validate :captcha_must_be_valid, if: :need_verify_captcha?
  validate :check_amount

  def initialize(opts = {})
    super
    self.product = Product.find(self.product_id)
    if buyer
      self.user_address = buyer.user_addresses.find(self.user_address_id) if self.user_address_id.present?
    end
  end

  def save
    if self.valid?
      ActiveRecord::Base.transaction do
        create_user
        create_user_address
        create_order_and_order_item
      end
      true
    else
      false
    end
  end

  private

  def create_user
    return true if buyer.present?

    self.buyer = User.create!(
      login: mobile, 
      mobile: mobile, 
      password: 'ubossFakepa22w0rd', 
      need_reset_password: true)
  end

  def create_user_address
    return true if user_address.present?

    self.user_address = UserAddress.create!(
      user: buyer,
      mobile: deliver_mobile,
      username: deliver_username,
      province: province,
      city: city,
      country: country,
      street: street)
  end

  def create_order_and_order_item
    pay_amount = order_items_attributes.map { |order_item| order_item[:pay_amount] }.sum
    self.order = Order.create!(
      user: buyer,
      user_address: user_address,
      pay_amount: pay_amount,
      order_items_attributes: order_items_attributes)
  end

  def order_items_attributes
    @order_items ||= [ 
      { product: product, user: buyer, amount: amount, pay_amount: product.present_price * amount.to_i } 
    ]
  end

  def check_amount
    if amount.to_i > product.reload.count
      errors.add(:amount, '库存不足')
    end
  end

  def need_mobile?
    self.buyer.blank?
  end

  def need_verify_captcha?
    buyer.blank? && mobile.present?
  end

  def captcha_must_be_valid
    if captcha != '123'
      errors.add(:captcha, '手机验证码错误')
    end
  end
  
end
