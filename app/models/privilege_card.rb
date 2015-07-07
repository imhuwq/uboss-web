class PrivilegeCard < ActiveRecord::Base

  belongs_to :user
  belongs_to :product

  validates :amount, :user_id, :product_id, presence: true
  validates_uniqueness_of :user_id, scope: :product_id
  validates_numericality_of :amount, less_than_or_equal_to: :product_first_level_reward

  private

  def product_first_level_reward
    product.share_amount_lv_1
  end

end
