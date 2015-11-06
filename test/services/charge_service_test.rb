require 'test_helper'

class ChargeServiceTest < ActiveSupport::TestCase

  test 'should validate orders pay' do
    orders = [
      create(:order, state: 'unpay'),
      create(:order, state: 'payed')
    ]
    assert_equal false, ChargeService.available_pay?(orders)

    orders = [
      create(:order, state: 'unpay'),
      create(:order, state: 'unpay')
    ]
    assert ChargeService.available_pay?(orders), 'Success for all unpay order'

    agent_user = create :agent_user
    agent_order = create(:order, state: 'unpay', user: agent_user)
    agent_order.expects(:official_agent?).returns(true)

    orders = [
      agent_order,
      create(:order, state: 'unpay')
    ]
    assert_not ChargeService.available_pay?(orders), 'Faile for repeat agent order'
  end

  test 'should process_paid_result success' do
    order_charge = create(:charge_with_orders)
    assert order_charge.paid_at.blank?, "paid_at should be blank when nopaid"

    pay_time = Time.current
    pay_total_fee = order_charge.orders.sum(:pay_amount)
    result = WxPay::Result[{
      'xml' => {
        "out_trade_no" => order_charge.pay_serial_number,
        "total_fee" => pay_total_fee,
        "time_end" => pay_time
      }
    }]

    assert_equal 0, order_charge.orders.sum(:paid_amount)

    WxPay::Sign.stubs(:verify?).returns(true)
    result.stubs(:success?).returns(true)

    assert ChargeService.process_paid_result(result: result), "process pay reponse should success"
    assert_equal pay_time, order_charge.reload.paid_at
    assert_equal pay_total_fee, order_charge.orders.sum(:paid_amount)
    assert_equal pay_total_fee, order_charge.paid_amount
    assert_equal [Order.states[:payed]], order_charge.orders.pluck(:state).uniq

    assert_not ChargeService.process_paid_result(result: result), "reprocess paid reponse should fail"
  end

end
