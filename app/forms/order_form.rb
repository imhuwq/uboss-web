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

  attr_accessor :sharing_node, :product, :buyer, :user_address, :order, :session

  validates :product_id, :amount, presence: true
  validates :mobile, presence: true, mobile: true, if: -> { self.buyer.blank? }
  validates :deliver_mobile, :deliver_username, :street, presence: true, if: -> { self.user_address_id.blank? }
  validates :deliver_mobile, mobile: true, allow_blank: true
  validate  :captcha_must_be_valid, :mobile_blank_with_oauth, if: -> { self.buyer.blank? }
  validate  :check_amount

  delegate :traffic_expense, to: :product, prefix: :product

  def user_address
    return @user_address if @user_address.present?
    if buyer && user_address_id.present?
      @user_address = buyer.user_addresses.find(self.user_address_id)
    else
      @user_address = UserAddress.new(
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
  end

  def product
    @product ||= Product.find(self.product_id)
  end

  def sharing_node
    @sharing_node ||= SharingNode.find_by(code: self.sharing_code)
  end

  def real_price
    if sharing_node.present?
      product.present_price.to_f.to_d - sharing_node.privilege_amount.to_f.to_d
    else
      product.present_price.to_f.to_d
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
    self.buyer ||= User.find_by(login: mobile)
    if need_update_oauth_info?
      buyer.update_with_wechat_oauth(session['devise.wechat_data'].extra['raw_info'])
    elsif buyer.blank?
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
      user_address.save!
    end
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
      errors.add(:amount, :invalid)
    end
  end

  def captcha_must_be_valid
    if !MobileCaptcha.auth_code(mobile, captcha)
      errors.add(:captcha, :invalid)
    end
  end

  def mobile_blank_with_oauth
    user = User.find_by(login: mobile)
    if user.present? && user.weixin_openid.present? && session['devise.wechat_data'] &&
        session['devise.wechat_data'].extra['raw_info']['weixin_openid'] != user.weixin_openid
      errors.add(:mobile, '已绑定微信账号')
    end
  end

end
