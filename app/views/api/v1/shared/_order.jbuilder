json.extract!(order, :id, :seller_id, :number, :mobile, :state, :pay_amount,
              :created_at, :shiped_at, :signed_at, :completed_at)

json.amount order.order_item.amount
json.product do
  json.partial! 'api/v1/shared/product', product: order.product
end
