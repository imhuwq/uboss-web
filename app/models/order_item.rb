class OrderItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  belongs_to :product

  after_commit :reward_users, on: :create

  private

  def reward_users
    # TODO reward model
  end

end
