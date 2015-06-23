class SharingNode < ActiveRecord::Base

  acts_as_nested_set

  belongs_to :user
  belongs_to :product

  validates :user_id, :product_id, presence: true

  # NOTE also using databse uniq index
  validates_uniqueness_of :user_id, scope: [:product_id, :parent_id]
  validates_uniqueness_of :user_id, scope: [:product_id], if: -> { self.parent_id.blank? }

  before_create :set_code, :set_product

  private
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
