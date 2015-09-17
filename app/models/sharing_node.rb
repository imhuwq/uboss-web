class SharingNode < ActiveRecord::Base

  acts_as_nested_set

  belongs_to :user
  belongs_to :product
  belongs_to :seller, class_name: "User"

  validates :user_id, presence: true
  validates_presence_of :product_id, if: -> { self.seller_id.blank? }
  validates_presence_of :seller_id,  if: -> { self.product_id.blank? }

  # NOTE now using databse uniq index, do not remove this code
  # validates_uniqueness_of :user_id, scope: [:product_id, :parent_id]
  # validates_uniqueness_of :user_id, scope: [:product_id], if: -> { self.parent_id.blank? }
  # validates_uniqueness_of :user_id, scope: [:seller_id], if: -> { self.seller_id.present? }

  # NOTE not now!
  # validate :limit_sharing_rate

  before_create :set_code, :set_product

  delegate :amount, to: :privilege_card, prefix: :privilege, allow_nil: true

  class << self
    def find_or_create_by_resource_and_parent(user, resource, parent = nil)
      params = { user_id: user.id }
      params.merge!(parent_id: parent.id) if parent.present? && resource.is_a?(Product)

      case resource.class.name
      when 'User'
        params.merge!(seller_id: resource.id)
      when 'Product'
        params.merge!(product_id: resource.id)
      end

      node = where(params).order('updated_at DESC').first
      if node.blank?
        begin
          node = create!(params)
        rescue => e
          send_exception_message(e, params)
          node = nil
        end
      else
        node.touch
      end

      return nil if node.blank?
      node.persisted? ? node : nil
    end
  end

  #
  # 提供给从店铺节点打开的商品页面
  # 页面根据此节点，寻找分享者的最新商品分享节点
  #
  def lastest_product_sharing_node selling_product
    @lastest_product_sharing_node ||=
      if product_id.present?
        self
      else
        self.class.find_or_create_by_resource_and_parent(user, selling_product)
      end
  end

  #
  # 为店铺首页生成店铺分享节点
  #
  def lastest_seller_sharing_node shared_seller
    @lastest_seller_sharing_node ||=
      if seller_id.present?
        self
      else
        self.class.find_or_create_by_resource_and_parent(user, shared_seller)
      end
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
      errors[:base] << '您今天已经分享，UBOSS限制每天分享一件商品，感谢您的支持。'
    end
  end

  def set_product
    if parent_id.present? && parent.product_id.present?
      self.product_id = parent.product_id
    end
  end

  def set_code
    loop do
      self.code = SecureRandom.hex(10)
      break if !SharingNode.find_by(code: code)
    end
  end
end
