class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :cart
  belongs_to :product
  belongs_to :seller, class_name: "User"

  validates :cart_id, :product_id, :seller_id, presence: true
  #TODO sku [:order_id, :product_id]唯一
end
