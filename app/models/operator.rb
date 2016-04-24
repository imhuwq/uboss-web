class Operator < ActiveRecord::Base
  include Orderable
  include Userdelegator
  belongs_to :user
  has_many :shops
  has_many :incomes, class_name: 'OperatorIncome', foreign_key: :user_id, primary_key: :user_id
  attr_accessor :login
  
  enum state: {active: 0, disable: 1}
  validates :name, :mobile, presence: true
  validate :login_must_be_exist, on: :create
  validates :mobile, numericality: true, :length => { minimum: 11, maximum: 11 }
  before_validation :set_rates, on: :create
  before_validation :binding_user, if: -> { user.blank? }
  after_save :add_or_remove_operator_role!

  def binding_user
    self.user = User.find_by(login: login)
  end

  def income(segment=:all)
    segment = :all if not %w(today month all).include?(segment)
    segment = :current_month if segment.to_s == "month"
    incomes.send(segment).sum("operator_incomes.amount")
  end

  def turnovers(segment=:all)
    shops.online_turnovers(segment) + shops.offline_turnovers(segment)
  end

  private
  def login_must_be_exist
    if login.blank?
      errors.add(:login, '不能为空')
    else
      errors.add(:login, '不存在') if not User.exists?(login: login)
    end
  end

  def set_rates
    self.online_rate  = 0.5
    self.offline_rate = 0.05
  end

  def add_or_remove_operator_role!
    active? && user.add_role(:operator)
    disable? && user.remove_role(:operator)
  end
end
