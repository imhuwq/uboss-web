require 'test_helper'

class OrderChargeTest < ActiveSupport::TestCase

  test 'should assign_paid_amount_to_order should not over paid amount' do
    @order_charge = create :charge_with_orders, orders_count: 5
    charge_orders = @order_charge.orders

    assert_equal 0, charge_orders.sum(:paid_amount)

    @order_charge.paid_amount = @order_charge.pay_amount - 10
    @order_charge.assign_paid_amount_to_order
    assert_equal @order_charge.paid_amount, charge_orders.sum(:paid_amount)
  end

  test 'should assign_paid_amount_to_order with batch orders' do
    @order_charge = create :charge_with_orders, orders_count: 5
    charge_orders = @order_charge.orders

    assert_equal 0, charge_orders.sum(:paid_amount)

    @order_charge.paid_amount = @order_charge.pay_amount
    @order_charge.assign_paid_amount_to_order
    assert_equal @order_charge.paid_amount, charge_orders.sum(:paid_amount)
  end

  test 'should assign_paid_amount_to_order with single orders' do
    @order_charge = create :charge_with_orders, orders_count: 1
    charge_orders = @order_charge.orders

    assert_equal 0, charge_orders.sum(:paid_amount)
    assert_equal 1, charge_orders.size

    @order_charge.paid_amount = @order_charge.pay_amount
    @order_charge.assign_paid_amount_to_order
    assert_equal @order_charge.paid_amount, charge_orders.sum(:paid_amount)
  end

  test 'should close_prepay success' do
    @order_charge = create :charge_with_orders
    charge_orders = @order_charge.orders

    assert_equal true, @order_charge.reload.wx_prepay_valid?

    stub_wx_invoke_closeorder!
    @order_charge.close_prepay

    assert [nil], charge_orders.reload.pluck(:order_charge_id).uniq
    assert_not @order_charge.wx_prepay_valid?, 'prepay should be unvalid after close'
  end

  test 'should close_prepay fail and assign if paid' do
    @order_charge = create :charge_with_orders
    charge_orders = @order_charge.orders

    ChargeService.expects(:process_paid_result).returns(true).once
    stub_wx_invoke_closeorder!(data: {
      'result_code' => 'FAIL',
      'err_code' => 'ORDERPAID'
    })
    stub_wx_invoke_orderquery!

    @order_charge.close_prepay

    assert [@order_charge.id], charge_orders.reload.pluck(:order_charge_id).uniq
  end

  test 'should get wx_prepay_valid?' do
    @order_charge = create :charge_with_orders
    order_charge = create :order_charge, prepay_id: nil
    assert_not order_charge.wx_prepay_valid?, 'prepay unvalid cos nil prepay_id'
    order_charge.update prepay_id: 'prepay_id', prepay_id_expired_at: Time.current + 2.hours
    assert order_charge.wx_prepay_valid?, 'prepay valid'

    travel_to Time.current + 3.hours do
      assert_not order_charge.wx_prepay_valid?, 'prepay unvalid cos timeout'
    end
  end
end
