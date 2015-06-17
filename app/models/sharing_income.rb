class SharingIncome < ActiveRecord::Base

  belongs_to :user
  belongs_to :seller, class_name: 'User'
  belongs_to :order_item

  validates :user_id, :seller_id, :order_item_id, presence: true

end
