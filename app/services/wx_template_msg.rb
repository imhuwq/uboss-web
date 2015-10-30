module WxTemplateMsg extend self

  TOPCOLOR = "#FF0000"

  # touser = "oH-QWs9Pe19t1fLzOl3cF2plVDRA"
  # url = "http://stage.uboss.me/"
  # $weixin_client.send_template_msg(touser, template_id, url, topcolor, data)

  def order_payed_msg_to_seller(touser, url='', order={})                   # To 商家
    template_id = "eS1NVVg4N24hyqlEhjY5NAYieRZj5V9gTUPzUNLhXA4"     # 消息模板ID
    data = order_payed_msg_to_seller_data(order)

    $weixin_client.send_template_msg(touser, template_id, url, TOPCOLOR, data)
  end

  def order_payed_msg_to_buyer(touser, url='', order={})            # To 消费者
    template_id = "eS1NVVg4N24hyqlEhjY5NAYieRZj5V9gTUPzUNLhXA4"     # 消息模板ID
    data = order_payed_msg_to_buyer_data(order)

    $weixin_client.send_template_msg(touser, template_id, url, TOPCOLOR, data)
  end

  def order_payed_msg_to_agent(touser, url='', order={})                    # To 创客
    template_id = "eS1NVVg4N24hyqlEhjY5NAYieRZj5V9gTUPzUNLhXA4"     # 消息模板ID
    data = order_payed_msg_to_agent_data(order)

    $weixin_client.send_template_msg(touser, template_id, url, TOPCOLOR, data)
  end

  private

  def order_payed_msg_to_seller_data(order)
    {
      first: {
        value: "您有一个新订单买家已经付款，请及时查看并发货。",
        color: "#173177"
      },
      orderOrderNumber: {
        value: order.pay_serial_number,
        color: "#173177"
      },
      orderPaidAt: {
        value: order.paid_at,
        color: "#173177"
      },
      orderDetail: {
        value: order.detail,
        color: "#173177"
      },
      Remark: {
        value: "截止#{'30日10：40分'}，你尚有#{'10'}个订单未处理。",
        color: "#173177"
      }
    }
  end

  def order_payed_msg_to_buyer_data(order)
    {
      first: {
        value: "您的订单支付成功，我们开始为您打包商品，请耐心等待。",
        color: "#173177"
      },
      orderOrderNumber: {
        value: order.pay_serial_number,
        color: "#173177"
      },
      orderPaidAt: {
        value: order.paid_at,
        color: "#173177"
      },
      orderPaidAmount: {
        value: order.paid_amount,
        color: "#173177"
      },
      orderPrivilegeAmount: {
        value: order.privilege_amount,
        color: "#173177"
      },
      orderDeliveryInfo: {
        value: order.delivery_info,
        color: "#173177"
      },
      Remark: {
        value: "客官，收货后获得该商品的友情卡，无限量分享给好友打折，还能给自己返现哦！了解更多友情卡信息，可点击查看详情。",
        color: "#173177"
      }
    }
  end

  def order_payed_msg_to_agent_data(order)
    {
      first: {
        value: "您的商家有一个新订单买家已经付款，请提醒商家及时查看并发货。",
        color: "#173177"
      },
      orderSellerName: {
        value: order.seller_name,
        color: "#173177"
      },
      orderSellerMobile: {
        value: order.seller_mobile,
        color: "#173177"
      },
      orderOrderNumber: {
        value: order.pay_serial_number,
        color: "#173177"
      },
      orderPaidAt: {
        value: order.paid_at,
        color: "#173177"
      },
      orderDetail: {
        value: order.detail,
        color: "#173177"
      },
      Remark: {
        value: "截止#{'30日10：40分'}，商家尚有#{'10'}个订单未处理。",
        color: "#173177"
      }
    }
  end
end
