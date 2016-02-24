json.cache! ['admin', product] do
  json.extract! product,
    :id, :name, :original_price, :present_price, :count, :traffic_expense,
    :good_evaluation, :worst_evaluation, :better_evaluation, :best_evaluation, :bad_evaluation,
    :short_description, :image_url, :status, :carriage_template_id, :transportation_way
end
