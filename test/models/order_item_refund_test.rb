require 'test_helper'

class OrderItemRefundTest < ActiveSupport::TestCase
  test 'money必须大于0' do
    refund = build(:order_item_refund, money: 0)
    assert_not refund.save
  end


  test '未发货前退款,卖家同意' do
    refund = create(:order_item_refund)
    refund.approve!
    assert refund.approved?
  end

  test '未发货前退款,卖家拒绝' do
    refund = create(:order_item_refund)
    refund.decline!
    assert refund.declined?

    refund.repending!
    assert refund.may_decline?
  end

  test '发货后未收到货, 退款' do
    refund = create(:order_item_refund, refund_type: 'unreceipt_refund')
    refund.decline!
    assert refund.declined?

    refund.repending!
    assert refund.may_approve?
    assert refund.approve!
  end

  test '发货后已收到货, 仅退款' do
    refund = create(:order_item_refund, refund_type: 'receipted_refund')
    refund.decline!
    assert refund.declined?

    refund.repending!
    assert refund.may_approve?
    assert refund.approve!
  end

  test '退货退款' do
    refund = create(:order_item_refund, refund_type: 'return_goods_and_refund')
    assert refund.approve!
    assert refund.complete_express_number!
    assert refund.may_confirm_receive? && refund.may_decline_receive?
    assert refund.decline_receive!
    assert refund.complete_express_number!
    assert refund.confirm_receive!
  end
end
