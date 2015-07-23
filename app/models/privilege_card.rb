class PrivilegeCard < ActiveRecord::Base

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
    product.share_amount_lv_1 - amount
  end

  def privilege_amount= total_amount
    write_attribute(:amount, BigDecimal.new(total_amount) - product.privilege_amount)
  end

  def privilege_amount
    amount + product.privilege_amount
  end

  private

  def product_first_level_reward
    product.share_amount_lv_1
  end

end
