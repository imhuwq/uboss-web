require 'test_helper'

class OrderChargeTest < ActiveSupport::TestCase

  # test 'should check_and_close_prepay' do
  #
  # end
  #
  # test 'should assign_paid_amount_to_order' do
  #
  # end
  #
  # test 'should close_prepay' do
  #
  # end

  test 'should get wx_prepay_valid?' do
    order_charge = create :order_charge, prepay_id: nil
    assert_not order_charge.wx_prepay_valid?, 'prepay unvalid cos nil prepay_id'
    order_charge.update prepay_id: 'prepay_id', prepay_id_expired_at: Time.current + 2.hours
    assert order_charge.wx_prepay_valid?, 'prepay valid'

    travel_to Time.current + 3.hours
    assert_not order_charge.wx_prepay_valid?, 'prepay unvalid cos timeout'
  end
end
