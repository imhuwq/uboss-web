json.page page_param
json.page_size page_size
json.carriage_templates do
  json.array! @carriage_templates do |carriage_template|
    json.id carriage_template.id
    json.name carriage_template.name
  end
end
