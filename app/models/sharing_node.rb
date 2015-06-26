class SharingNode < ActiveRecord::Base

  acts_as_nested_set

  belongs_to :user
  belongs_to :product

  validates :user_id, :product_id, presence: true

  # NOTE also using databse uniq index
  validates_uniqueness_of :user_id, scope: [:product_id, :parent_id]
  validates_uniqueness_of :user_id, scope: [:product_id], if: -> { self.parent_id.blank? }
  validate :limit_sharing_rate

  before_create :set_code, :set_product

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
end
