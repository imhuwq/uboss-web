class AddProvinceToCertifications < ActiveRecord::Migration
  def change
    add_column :certifications, :province_code, :string
    add_column :certifications, :city_code, :string
    add_column :certifications, :district_code, :string

    say_with_time "Update EnterpriseAuthentication city" do
      ChinaCity.provinces.each do |province_name, province_code|
        ChinaCity.list(province_code).each do |city_name, city_code|
          certification = Certification.ransack(address_cont: city_name.gsub(/市/,'')).result.first
          if certification
            certification.update(province_code: province_code, city_code: city_code)
            print '.'.green
          end
        end
      end
      puts
    end
  end
end
