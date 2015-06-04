class OrderItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  belongs_to :product

  before_create :set_user_id

  private
  def set_user_id
    self.user_id = order.user_id
  end
end
