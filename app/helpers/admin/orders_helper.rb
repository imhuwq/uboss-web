module Admin::OrdersHelper
  def order_tag(order)
    content_tag "span", I18n.t(order.type.underscore, scope: 'tags.order'), class: "label label-primary"
  end
end
