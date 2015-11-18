class PrivilegeCard < ActiveRecord::Base

  include Orderable

  belongs_to :user
  belongs_to :seller, class_name: "User"

  validates :user_id, :seller_id, presence: true
  validates_uniqueness_of :user_id, scope: :seller_id

  def self.find_or_active_card(user_id, seller_id)
    card = PrivilegeCard.find_or_create_by(user_id: user_id, seller_id: seller_id)
    card.update_column(:actived, true) if not card.actived?
    card
  end

  def discount(product_inventory)
    (product_inventory.price - privilege_amount(product_inventory)) * 10 / product_inventory.price
  end

  def returning_amount(product_inventory)
    result = product_inventory.share_amount_lv_1 - amount(product_inventory)
    result > 0 ? result : 0
  end

  def privilege_amount(product_inventory)
    result = amount(product_inventory) + product_inventory.privilege_amount
    result > product_inventory.max_privilege_amount ? product_inventory.max_privilege_amount : result
  end

  def amount(product_inventory)
    (user.privilege_rate * product_inventory.share_amount_lv_1 / 100).truncate(2)
  end

end
