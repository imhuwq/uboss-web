class UserAddress < ActiveRecord::Base
  include Orderable

  belongs_to :user

  validates :user, :username, :mobile, :building, :province, :city, :street, presence: true
  validates :mobile, mobile: true

  before_save :set_default_get_address, :set_default_post_address

  def to_s
    @province = ChinaCity.get(province) rescue province
    @city = ChinaCity.get(city) rescue city
    @area = ChinaCity.get(area) rescue area
    "#{@province}#{@city}#{@area}#{building}"
  end

  def set_default_get_address
    if usage[:defalult_get_address] = 'true'
      user_addresses = UserAddress.where(user_id: user_id).where('usage @> ?', {defalult_get_address: true}.to_json)
      user_addresses.each do |obj|
        obj.usage[:defalult_get_address] = 'false'
        obj.save(validate: false)
      end
    end
  end
  
  def set_default_post_address
    if usage[:defalult_post_address] = 'true'
      user_addresses = UserAddress.where(user_id: user_id).where('usage @> ?', {defalult_post_address: true}.to_json)
      user_addresses.each do |obj|
        obj.usage[:defalult_post_address] = 'false'
        obj.save(validate: false)
      end
    end
  end

end
