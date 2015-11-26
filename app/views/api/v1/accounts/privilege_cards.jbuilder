json.page page_param
json.page_size page_size
json.privilege_cards do
  json.array! @privilege_cards, partial: 'api/v1/shared/privilege_card', as: :privilege_card
end
