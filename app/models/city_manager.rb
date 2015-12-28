class CityManager < ActiveRecord::Base
  include Userdelegator
  CATEGORIES = {firstline: 1, secondline: 2, thirdline: 3, fourthline: 4, fifthline: 5}
  belongs_to :user
  has_many :enterprise_authentications, foreign_key: :city_code, primary_key: :city
  validates_numericality_of :rate, greater_than: 0, less_than: 1
  validates :category, presence: true

  enum category: CATEGORIES

  validates :city, :presence => true, :uniqueness => true

  scope :contracted, -> { where("user_id > 0") }

  after_save :add_city_manager_role, if: :user_id_changed?

  def city_name
    ChinaCity.get(city)
  end

  def add_city_manager_role
    if previous_user_id=previous_changes[:user_id]
      User.find(previous_user_id).try(:remove_role, :city_manager)
    end
    user.add_role(:city_manager) if user.present?
  end
end
