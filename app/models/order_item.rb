class OrderItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :order
  belongs_to :product

  delegate :name, to: :product, prefix: true

  after_commit :reward_users, on: :create

  private

  def reward_users
    # TODO reward model
  end

end
