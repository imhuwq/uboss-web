class PrivilegeCard < ActiveRecord::Base

  include Orderable

  belongs_to :user
  belongs_to :product

  validates :amount, :user_id, :product_id, presence: true
  validates_uniqueness_of :user_id, scope: :product_id
  validates_numericality_of :amount,
    less_than_or_equal_to: :product_first_level_reward,
    greater_than_or_equal_to: 0

  delegate :present_price, to: :product

  def discount
    (product.present_price - privilege_amount) * 10 / product.present_price
  end

  def returning_amount
    result = product.share_amount_lv_1 - amount
    result > 0 ? result : 0
  end

  def privilege_amount= total_amount
    write_attribute(:amount, BigDecimal.new(total_amount) - product.privilege_amount)
  end

  def privilege_amount
    result = amount + product.privilege_amount
    result > product.share_amount_lv_1 ? product.share_amount_lv_1 : result
  end

  private

  def product_first_level_reward
    product.share_amount_lv_1
  end

end
