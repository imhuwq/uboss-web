module OrderItemRefundsHelper

  def refund_text_color(refund)
    'red-color' if refund.wait_seller?
  end

  def check_refund_and_get_money(order_item, refund)
    order = order_item.order
    return [false, order_item.pay_amount] if order.state == 'payed'
    return [true, order_item.pay_amount] if refund.refund_type == 'receipted_refund'
    return [refund.aasm_state == 'declined', order_item.pay_amount] if refund.refund_type == 'unreceipt_refund'
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

    elsif refund.aasm_state.in?(['approved', 'declined', 'decline_received'])
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
      return '申请售后' if order.completed? || order.signed?
      return '退款'
    elsif last_refund.present?
      return '退款成功' if last_refund.finished?
      return '退款撤销' if last_refund.cancelled?
      return '退款关闭' if last_refund.closed?
      return '退款中'
    end
  end

  def admin_refund_state(refund)
    return '退款'       if refund.pending? && refund.refund_type == :refund
    return '退款不退货' if refund.pending? && !refund.refund_type_include_goods?
    return '退款退货'   if refund.pending? && refund.refund_type_include_goods?
    return 'UBOSS介入'  if refund.applied_uboss?
    return '退款成功'   if refund.finished?
    return '退款撤销'   if refund.cancelled?
    return '退款关闭'   if refund.closed?
    return '退款中'
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

  def render_refund_modal(partial, opts = {})
    render partial: "admin/order_item_refunds/refund_modal", locals: {page: partial, title: opts[:title]}
  end

  def render_refund_info(refund)
    render partial: "admin/order_item_refunds/aasm/state_info/#{refund.aasm_state}", locals: {order_item_refund: refund}
  end
end
