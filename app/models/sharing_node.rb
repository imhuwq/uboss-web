class SharingNode < ActiveRecord::Base

  acts_as_nested_set

  belongs_to :user
  belongs_to :product

  validates :user_id, :product_id, presence: true

  # NOTE also using databse uniq index
  # validates_uniqueness_of :user_id, scope: [:product_id, :parent_id]
  # validates_uniqueness_of :user_id, scope: [:product_id], if: -> { self.parent_id.blank? }
  # validate :limit_sharing_rate

  before_create :set_code, :set_product, :set_order_id

  delegate :amount, to: :privilege_card, prefix: :privilege, allow_nil: true

  def self.find_or_create_user_last_sharing_by_product(user, product)
    node = where(user: user, product: product).order('id DESC').last
    if node.blank?
      node = create(user: user, product: product)
    end
    node.persisted? ? node : nil
  end

  def privilege_amount
    privilege_card.present? ? privilege_card.privilege_amount : 0
  end

  def to_param
    code
  end

  def privilege_card
    @privilege_card ||= PrivilegeCard.find_by(user_id: user_id, product_id: product_id, actived: true)
  end

  private
  def limit_sharing_rate
    if self.class.where('created_at > ?', Time.now.beginning_of_day).where(user_id: user_id).exists?
      errors[:base] << '您今天已经分享，UBoss限制每天分享一件商品，感谢您的支持。'
    end
  end

  def set_product
    if parent_id.present?
      self.product_id = parent.product_id
    end
  end

  def set_code
    loop do
      self.code = SecureRandom.hex(10)
      break if !SharingNode.find_by(code: code)
    end
  end

  def set_order_id
    order_item_id.present? && self.order_id ||= order_item.order_id
  end
end
