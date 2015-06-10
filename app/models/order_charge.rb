class OrderCharge < ActiveRecord::Base

  belongs_to :order

  validates :charge_id, presence: true

  def check_paid?
    charge = Pingpp::Charge.retrieve(charge_id)
    charge[:paid]
  end

end
