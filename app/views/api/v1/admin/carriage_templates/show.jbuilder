json.extract! @carriage_template, :id, :name, :created_at, :updated_at
json.different_areas do
  json.array! @carriage_template.different_areas do |different_area|
    json.extract! different_area, :id, :first_item, :carriage, :extend_item, :extend_carriage

    json.regions do
      json.array! different_area.regions do |region|
        json.extract! region, :id, :name, :numcode
      end
    end

  end
end
