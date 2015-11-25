module WxTemplateMsg extend self

  # touser = "oH-QWs9Pe19t1fLzOl3cF2plVDRA"
  # $weixin_client.send_template_msg(touser, template_id, url, topcolor, data)

  # 订单支付成功(消费者）
  def order_payed_msg_to_buyer(touser, order)
    send_template_msg(touser, 1, '', order_payed_msg_to_buyer_data(order))
  end

  # 新订单通知（商家）
  def order_payed_msg_to_seller(touser, order)
    send_template_msg(touser, 2, '', order_payed_msg_to_seller_data(order))
  end

  # 新订单通知（创客）
  def order_payed_msg_to_agent(touser, order)
    send_template_msg(touser, 2, '', order_payed_msg_to_agent_data(order))
  end

  # 退款申请通知（商家） TODO 买家申请退款
  def order_refund_msg_to_seller(touser, refund)
    send_template_msg(touser, 3, '', order_refund_msg_to_seller_data(refund))
  end

  # 退款申请审核结果（消费者）（成功） TODO 微信退款成功
  def order_refund_success_msg_to_buyer(touser, refund)
    send_template_msg(touser, 4, '', order_refund_success_msg_to_buyer_data(refund))
  end

  # 退款申请审核结果（消费者）（失败） TODO 卖家选择发货、超时填写发货信息、超时处理卖家请求、微信退款失败
  def order_refund_fail_msg_to_buyer(touser, refund)
    send_template_msg(touser, 4, '', order_refund_fail_msg_to_buyer_data(refund))
  end

  # 收益到帐提醒 SharingIncome after_create
  def income_arrive_notify_msg_to_buyer(touser, sharing_income)
    send_template_msg(touser, 5, '', income_arrive_notify_msg_to_sharer_data(sharing_income))
  end

  private

  def send_template_msg(touser, template_id, url, data)
    $weixin_client.send_template_msg(touser, find_template(template_id), url, "#FF0000", data)
  end

  def find_template(id)
    if Rails.env.production?
      case id
      when 1 then "uEueB-odxX1p9U-pTD7GmEjxkUCEAz_fpt_U3UOIotQ"  # 订单支付成功提示
      when 2 then "zYtFNsBK44hvlAp9Z0v8Yt2EOiH1dW2rUxSOZ5PImk8"  # 新订单提醒
      when 3 then "DbSc6uRm0_Nx4dr57_Wtl2xSBM3q93WjGFwDkt4tBs0"  # 退款申请通知
      when 4 then "oAsNI8sdRQHfXdCsuV8pebfvFcNHKcm9ty30UJUNqpQ"  # 退款申请审核结果
      when 5 then "wg-qHiJ7H95svioAmrvpJgx-6IP2u5FK-_frEANFeLo"  # 收益发放通知
      end
    else
      case id
      when 1 then "kvih1TfO8485PIGZVVhh6itqMqnboa_AePpy22b9T6s"
      when 2 then "d4j3f5z3XpoqcNG5NhUJhfEZfasp6zZ6mc8450TIT1M"
      when 3 then "F0YVHZRcB0IlJL8Fm8cjhJIdnh1FXUER5peJ03i4-_s"
      when 4 then "cMVdx_bBZAEnXoRwTZAHcCf7ZXaGGIes1OAp0NeYxhQ"
      when 5 then "uR5MyG4QNYrwGHCtQcfgDpA3JkmHqLt2JIC5OwkAT-M"
      end
    end
  end

  def order_payed_msg_to_buyer_data(order)
    {
      first: {
        value: "您的订单支付成功，我们开始为您打包商品。\n",
        color: "#173177"
      },
      keyword1: {
        value: order.number,
        color: "#000"
      },
      keyword2: {
        value: date_format(order.paid_at),
        color: "#000"
      },
      keyword3: {
        value: "微信支付#{order.pay_amount}元",
        color: "#000"
      },
      remark: {
        value: "友情卡抵扣：#{order.total_privilege_amount}元\n收货信息：#{order.ship_info}\n\n客官，确认收货后获得该商品的友情卡，给好友打折，给自己返现！",
        color: "#000"
      }
    }
  end


  def order_payed_msg_to_seller_data(order)
    {
      first: {
        value: "您有一个新订单买家已经付款，请及时查看并发货。\n",
        color: "#173177"
      },
      keyword1: {
        value: order.number,
        color: "#000"
      },
      keyword2: {
        value: date_format(order.paid_at),
        color: "#000"
      },
      remark: {
        value: "订单状态：已付款\n订单详情：#{order.order_charge.orders_detail}\n\n截止 #{Time.now.strftime('%d日 %H:%M')}，您尚有#{seller_paid_orders_count(order).try(:count)}个订单未处理。",
        color: "#000"
      }
    }
  end

  def order_payed_msg_to_agent_data(order)
    {
      first: {
        value: "您的商家有一个新订单买家已经付款，请提醒商家及时查看并发货。\n",
        color: "#173177"
      },
      keyword1: {
        value: order.number,
        color: "#000"
      },
      keyword2: {
        value: date_format(order.paid_at),
        color: "#000"
      },
      remark: {
        value: "商家名字：#{order.seller.identify}\n商家电话：#{order.seller.mobile}\n订单状态：已付款\n\n截止 #{Time.now.strftime('%d日 %H:%M')}，该商家尚有#{seller_paid_orders_count(order).try(:count)}个订单未处理。",
        color: "#000"
      }
    }
  end

  def seller_paid_orders_count(order)
    Order.where(seller_id: order.seller_id, state: 1)
  end

  def order_refund_msg_to_seller_data(refund)
    {
      first: {
        value: "有一位买家申请退款，请及时处理\n",
        color: "#173177"
      },
      orderProductPrice: {
        value: "#{refund.money}元",
        color: "#000"
      },
      orderProductName: {
        value: refund.order_item.product_name,
        color: "#000"
      },
      orderName: {
        value: refund.order_item.order.number,
        color: "#000"
      },
      remark: {
        value: "\n买家手机：#{refund.order_item.order.mobile}\n\n如有疑问，可联系客服400-886-4414",
        color: "#000"
      }
    }
  end

  def order_refund_success_msg_to_buyer_data(refund)
    {
      first: {
        value: "您的退款申请已经有结果了\n",
        color: "#173177"
      },
      keyword1: {
        value: '退款成功',
        color: "#000"
      },
      keyword2: {
        value: "#{refund.money}元",
        color: "#000"
      },
      keyword3: {
        value: '符合退款条件',
        color: "#000"
      },
      remark: {
        value: "\n\n很抱歉给你带来了不好的购物体验，请今后继续支持我们。",
        color: "#000"
      }
    }
  end

  def order_refund_fail_msg_to_buyer_data(refund)
    # 不符合退款条件或超时自动关闭
    fail_reason = refund.closed? ? '卖家选择发货，退款申请自动关闭' : '超时自动关闭'

    {
      first: {
        value: "您的退款申请已经有结果了\n",
        color: "#173177"
      },
      keyword1: {
        value: '退款失败',
        color: "#000"
      },
      keyword2: {
        value: "#{refund.money}元",
        color: "#000"
      },
      keyword3: {
        value: fail_reason,
        color: "#000"
      },
      remark: {
        value: "\n\n如有疑问，可联系客服400-886-4414",
        color: "#000"
      }
    }
  end

  def income_arrive_notify_msg_to_sharer_data(sharing_income)
    {
      first: {
        value: "你申请的退款已经有结果了\n",
        color: "#173177"
      },
      keyword1: {
        value: sharing_income.amount,
        color: "#000"
      },
      keyword2: {
        value: date_format(sharing_income.created_at),
        color: "#000"
      },
      remark: {
        value: "\n【分享友情卡，帮朋友打折，给自己收益】UBOSS，一个边买边赚的商城！详情请电脑登录 uboss.cn 查看。",
        color: "#000"
      }
    }
  end

  def date_format(date)
    date.try(:strftime, '%Y%m%d %H:%M:%S')
  end

end
