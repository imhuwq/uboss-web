module OrderItemRefundsHelper
  def refund_timeout(refund)
    refund_timeout_2_days = Rails.application.secrets.refund_timeout['days_2']
    refund_timeout_5_days = Rails.application.secrets.refund_timeout['days_5']
    refund_timeout_7_days = Rails.application.secrets.refund_timeout['days_7']
    refund_timeout_10_days = Rails.application.secrets.refund_timeout['days_10']

    if refund.aasm_state == 'pending'
      return refund_timeout_2_days if refund.refund_type == 'refund'
      return refund_timeout_5_days if refund.refund_type == 'receipted_refund' || refund.refund_type == 'unreceipt_refund' || refund.refund_type == 'return_goods_and_refund' || refund.refund_type == 'after_sale_only_refund' || refund.refund_type == 'after_sale_return_goods_and_refund'

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
