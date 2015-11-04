module OrderItemRefundsHelper

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
    if refunds.blank?
      new_order_item_order_item_refund_path(order_item_id: order_item.id)
    else
      order_item_order_item_refund_path(order_item_id: order_item.id, id: last_refund.id)
    end
  end
end
