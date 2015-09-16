class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product
  belongs_to :seller, class_name: "User"

  validates :cart_id, :product_id, :seller_id, presence: true
  validates :product_id, scope: :cart_id

  delegate :image_url, :name, :original_price, :present_price, to: :product
end
