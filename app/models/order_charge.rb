class OrderCharge < ActiveRecord::Base

  attr_reader :charge

  belongs_to :order

  validates :charge_id, presence: true

  def check_paid?
    @charge ||= Pingpp::Charge.retrieve(charge_id)
    @charge[:paid]
  end
  alias_method :paid?, :check_paid?

end
