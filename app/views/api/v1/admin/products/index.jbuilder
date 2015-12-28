json.page page_param
json.page_size page_size
json.products do
  json.array! @products, partial: 'api/v1/shared/product', as: :product
end
