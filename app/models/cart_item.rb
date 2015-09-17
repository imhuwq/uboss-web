class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product
  belongs_to :seller, class_name: "User"

  validates_presence_of   :cart_id, :product_id, :seller_id
  validates_uniqueness_of :product_id, scope: :cart_id

  delegate :image_url, :name, :original_price, :present_price, to: :product
end
