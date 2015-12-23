class ServiceOrderForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::Model

  ATTRIBUTES = [:mobile, :captcha, :product_id, :product_inventory_id, :amount, :bind_mobile, :sharing_code]

  ATTRIBUTES.each do |order_attr|
    attr_accessor order_attr
  end

  attr_accessor :session, :sharing_node, :product, :product_inventory, :buyer, :order

  #validates :amount, presence: true, if: -> { self.product_id }
  validates :mobile, presence: true, mobile: true, if: -> { self.buyer.blank? }
  validates :seller_ids, :cart_item_ids, presence: true, if: -> { self.product_id.blank? }
  validate  :captcha_must_be_valid, :mobile_blank_with_oauth, if: -> { self.buyer.blank? }
  validate  :product_must_be_valid

  def product
    @product ||= ServiceProduct.find(self.product_id)
  end

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

  def privilege_amount
    sharing_node.present? ? sharing_node.privilege_amount(self.product_inventory) : 0.0
  end

  def total_privilege_amount
    privilege_amount*amount.to_i
  end

  def total_price
    product.present_price*amount.to_i - total_privilege_amount
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

  def create_order_and_order_item
    self.order =
      ServiceOrder.create!([{
        user: buyer,
        seller: product.user,
        mobile: bind_mobile,
        order_items_attributes: order_items_attributes
    }])
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

  def product_must_be_valid
    if !product_inventory.saling?
      errors.add(:base, "该商品不可售")
    elsif amount.to_i > product_inventory.reload.count
      self.amount = product_inventory.count
      errors.add(:base, "该商品库存不足，最多购买 #{amount} 件")
    elsif amount.to_i > 1 && product.is_official_agent?
      self.amount = 1
      errors.add(:base, '创客权只能购买一个')
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
