class CityManager < ActiveRecord::Base
  include Userdelegator
  CATEGORIES = {firstline: 1, secondline: 2, thirdline: 3, fourthline: 4, fifthline: 5}
  belongs_to :user
  has_many :enterprise_authentications, foreign_key: :city_code, primary_key: :city

  enum category: CATEGORIES

  validates :city, :presence => true, :uniqueness => true, :inclusion => { :in => ChinaCity.provinces.map(&:last) }

  scope :contracted, -> { where("user_id > 0") }

  def city_name
    ChinaCity.get(city)
  end
end
