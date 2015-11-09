namespace :region_db do
  desc 'init region data'
  task create_region: :environment do
    puts '开始添加行政区域'

    ChinaCity.provinces.each do |name, code|
      province = Region.find_or_create_by(name: name, numcode: code)

      ChinaCity.list(code).each do |city_name, city_code|
        city = Region.find_or_create_by(name: city_name, numcode: city_code, parent_id: province.id )

        ChinaCity.list(city_code).each do |area_name, area_code|
          Region.find_or_create_by(name: city_name, numcode: city_code, parent_id: city.id )
        end
      end
    end

    puts '行政区域添加成功!'
  end
end
