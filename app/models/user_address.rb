class UserAddress < ActiveRecord::Base
  include Orderable

  belongs_to :user

  validates :username, :mobile, :building, :province, :city, presence: true
  validates :mobile, mobile: true

  def to_s
    "#{ChinaCity.get(province)}#{ChinaCity.get(city)}#{ChinaCity.get(area)}#{street}#{building}"
  end

end
