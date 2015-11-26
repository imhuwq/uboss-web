json.page page_param
json.page_size page_size
json.product_inventories do
  json.array! @product_inventories,
    partial: 'api/v1/shared/product_inventory', as: :product_inventory
end
