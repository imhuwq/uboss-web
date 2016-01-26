module Admin::OrdersHelper
  def order_tag(order)
    text = I18n.t(order.type.underscore, scope: 'tags.order')
    if text
      content_tag "span", text, class: "label label-primary"
    end
  end
end
