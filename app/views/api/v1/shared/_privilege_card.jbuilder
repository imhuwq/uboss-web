json.extract! privilege_card,
  :id, :amount, :actived

json.user do
  json.partial! 'api/v1/shared/user', user: privilege_card.user
end

json.product do
  json.partial! 'api/v1/shared/product', product: privilege_card.product
end
