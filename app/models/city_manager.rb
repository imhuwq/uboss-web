class CityManager < ActiveRecord::Base
  CATEGORIES = {firstline: 1, secondline: 2, thirdline: 3, fourthline: 4, fifthline: 5}
  belongs_to :user
  enum category: CATEGORIES
  delegate :identify, :mobile, :avatar, to: :user, allow_nil: true, prefix: true
  
  scope :contracted, -> { where("user_id > 0") }

  def city_name
    ChinaCity.get(city)
  end
end
