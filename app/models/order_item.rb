class OrderItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  belongs_to :product

  before_create :set_user_id
  after_commit :reward_users, on: :create

  private

  def reward_users
    # TODO reward model
  end

  def set_user_id
    self.user_id = order.user_id
  end
end
