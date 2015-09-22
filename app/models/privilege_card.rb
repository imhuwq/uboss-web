class PrivilegeCard < ActiveRecord::Base

  include Orderable

  belongs_to :user
  belongs_to :seller, class_name: "User"

  validates :user_id, :seller_id, presence: true
  validates_uniqueness_of :user_id, scope: :seller_id

  def discount(product)
    (product.present_price - privilege_amount(product)) * 10 / product.present_price
  end

  def returning_amount(product)
    result = product.share_amount_lv_1 - amount(product)
    result > 0 ? result : 0
  end

  def privilege_amount(product)
    result = amount(product) + product.privilege_amount
    result > product.share_amount_lv_1 ? product.share_amount_lv_1 : result
  end

  def amount(product)
    user.privilege_rate * product.share_amount_lv_1 / 100
  end

end
