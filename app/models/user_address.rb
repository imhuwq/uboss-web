class UserAddress < ActiveRecord::Base
  include Orderable

  belongs_to :user

  validates :username, :mobile, :building, :province, :city, presence: true
  validates :mobile, mobile: true

  def to_s
    @province = ChinaCity.get(province) rescue province
    @city = ChinaCity.get(city) rescue city
    @area = ChinaCity.get(area) rescue area
    "#{@province}#{@city}#{@area}#{building}"
  end

end
