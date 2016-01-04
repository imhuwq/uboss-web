class CityManager < ActiveRecord::Base

  include Userdelegator
  include Orderable

  CATEGORIES = {firstline: 1, secondline: 2, thirdline: 3, fourthline: 4, fifthline: 5}

  belongs_to :user
  has_many :enterprise_authentications, foreign_key: :city_code, primary_key: :city

  validates_numericality_of :rate, greater_than: 0, less_than: 1
  validates :category, presence: true
  validates_uniqueness_of :user_id, message: "该用户以绑定其他城市", allow_nil: true
  validates :city, presence: true, uniqueness: true

  enum category: CATEGORIES

  scope :contracted, -> { where("user_id > 0") }

  after_save :update_city_manager_role, if: :user_id_changed?

  def turnovers(intervel='today')
    order_scope = Order.have_paid
    if %w(today month all).include?(intervel)
      order_scope = order_scope.send(intervel)
    else
      order_scope.today
    end
    order_scope.where(seller_id: enterprise_authentications.pass.pluck(:user_id)).sum(:paid_amount)
  end

  def city_name
    ChinaCity.get(city)
  end

  def update_city_manager_role
    if user_id_was.present?
      User.find_by_id(user_id_was).try(:remove_role, :city_manager)
    end
    user.add_role(:city_manager) if user.present?
  end
end
