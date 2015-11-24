module WxTemplateMsg extend self

  TOPCOLOR = "#FF0000"
  # touser = "oH-QWs9Pe19t1fLzOl3cF2plVDRA"
  # $weixin_client.send_template_msg(touser, template_id, url, topcolor, data)

  # 订单支付成功(消费者）
  def order_payed_msg_to_buyer(touser, order)
    template_id = "kvih1TfO8485PIGZVVhh6itqMqnboa_AePpy22b9T6s"     # 消息模板ID
    data = order_payed_msg_to_buyer_data(order)

    $weixin_client.send_template_msg(touser, template_id, 'http://uboss.me/about', TOPCOLOR, data)
  end

  # 新订单通知（商家）
  def order_payed_msg_to_seller(touser, order)
    template_id = "d4j3f5z3XpoqcNG5NhUJhfEZfasp6zZ6mc8450TIT1M"
    data = order_payed_msg_to_seller_data(order)

    $weixin_client.send_template_msg(touser, template_id, '', TOPCOLOR, data)
  end

  # 新订单通知（创客）
  def order_payed_msg_to_agent(touser, order)
    template_id = "d4j3f5z3XpoqcNG5NhUJhfEZfasp6zZ6mc8450TIT1M"
    data = order_payed_msg_to_agent_data(order)

    $weixin_client.send_template_msg(touser, template_id, '', TOPCOLOR, data)
  end

  # 退款申请通知（商家） TODO 买家申请退款
  def order_refund_msg_to_seller(touser, refund)
    template_id = "F0YVHZRcB0IlJL8Fm8cjhJIdnh1FXUER5peJ03i4-_s"
    data = order_refund_msg_to_seller_data(refund)

    $weixin_client.send_template_msg(touser, template_id, '', TOPCOLOR, data)
  end

  # 退款申请审核结果（消费者）（成功） TODO 微信退款成功
  def order_refund_success_msg_to_buyer(touser, refund)
    template_id = "cMVdx_bBZAEnXoRwTZAHcCf7ZXaGGIes1OAp0NeYxhQ"
    data = order_refund_success_msg_to_buyer_data(refund)

    $weixin_client.send_template_msg(touser, template_id, '', TOPCOLOR, data)
  end

  # 退款申请审核结果（消费者）（失败） TODO 卖家选择发货、超时填写发货信息、超时处理卖家请求、微信退款失败
  def order_refund_fail_msg_to_buyer(touser, refund)
    template_id = "cMVdx_bBZAEnXoRwTZAHcCf7ZXaGGIes1OAp0NeYxhQ"
    data = order_refund_fail_msg_to_buyer_data(refund)

    $weixin_client.send_template_msg(touser, template_id, '', TOPCOLOR, data)
  end

  # 收益到帐提醒 SharingIncome after_create
  def income_arrive_notify_msg_to_buyer(touser, sharing_income)
    template_id = "uR5MyG4QNYrwGHCtQcfgDpA3JkmHqLt2JIC5OwkAT-M"
    data = income_arrive_notify_msg_to_sharer_data(sharing_income)

    $weixin_client.send_template_msg(touser, template_id, '', TOPCOLOR, data)
  end

  private

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
        value: "\n友情卡抵扣：#{order.total_privilege_amount}元\n收货信息：#{order.ship_info}\n\n客官，收货后获得该商品的友情卡，给好友打折，给自己返现！",
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
        value: "\n订单状态：已付款\n订单详情：#{order.detail}\n\n截止#{Time.now.strftime('%d日 %H:%M')}，您尚有#{seller_paid_orders_count(order)}个订单未处理。",
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
        value: "\n商家名字：#{order.seller.identify}\n商家电话：#{order.seller.mobile}\n订单状态：已付款\n\n截止#{Time.now.strftime('%d日 %H:%M')}，该商家尚有#{seller_paid_orders_count(order)}个订单未处理。",
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
        value: date_format(sharing_income.create_at),
        color: "#000"
      },
      remark: {
        value: "\n\n【分享友情卡，帮朋友打折，给自己收益】\nUBOSS，一个边买边赚的商城！详情请电脑登录 uboss.cn 查看。",
        color: "#000"
      }
    }
  end

  def date_format(date)
    date.strftime('%Y%m%d %H:%M:%S')
  end

end
