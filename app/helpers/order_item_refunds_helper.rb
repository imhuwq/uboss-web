module OrderItemRefundsHelper

  def can_reapply?(order_item)
    OrderItemRefund.where(order_item_id: order_item.id, order_state: Order.states[order_item.order.state]).blank?
  end

  def check_refund_and_get_money(order_item, refund)
    order = order_item.order
    return [false, order_item.pay_amount] if order.state == 'payed'
    return [true, order_item.pay_amount] if refund.refund_type == 'receipted_refund'
    return [false, order_item.pay_amount] if refund.refund_type == 'unreceipt_refund'
    return [true, order_item.pay_amount] if refund.refund_type == 'return_goods_and_refund'
    return [true, order_item.pay_amount] if refund.refund_type == 'after_sale_only_refund'
    return [true, order_item.pay_amount] if refund.refund_type == 'after_sale_return_goods_and_refund'
  end

  def refund_timeout(refund)
    refund_timeout_2_days = Rails.application.secrets.refund_timeout['days_2']
    refund_timeout_5_days = Rails.application.secrets.refund_timeout['days_5']
    refund_timeout_7_days = Rails.application.secrets.refund_timeout['days_7']
    refund_timeout_10_days = Rails.application.secrets.refund_timeout['days_10']

    if refund.aasm_state == 'pending'
      return refund_timeout_2_days if refund.refund_type == 'refund'
      return refund_timeout_5_days if refund.refund_type.in?(['receipted_refund', 'unreceipt_refund', 'return_goods_and_refund', 'after_sale_only_refund', 'after_sale_return_goods_and_refund'])

    elsif refund.aasm_state == 'declined' || refund.aasm_state == 'approved'
      refund_timeout_7_days

    elsif refund.aasm_state == 'completed_express_number'
      refund_timeout_10_days
    end
  end

  def order_item_refund_state(order_item)
    refunds = order_item.order_item_refunds
    last_refund = order_item.last_refund
    order = order_item.order
    if refunds.blank?
      return '退款' if order.payed?
      return '申请售后' if order.completed? || order.signed?
    elsif last_refund.present? && !last_refund.finished?
      '退款中'
    elsif last_refund.finished?
      '退款成功'
    end
  end

  def order_item_refund_url(order_item)
    refunds = order_item.order_item_refunds
    last_refund = order_item.last_refund
    if order_item.order.may_ship? && refunds.blank?
      new_order_item_order_item_refund_path(order_item_id: order_item.id, refund_type: 'refund')
    elsif refunds.blank?
      service_select_order_item_order_item_refunds_path(order_item_id: order_item.id)
    else
      order_item_order_item_refund_path(order_item_id: order_item.id, id: last_refund.id)
    end
  end
end
