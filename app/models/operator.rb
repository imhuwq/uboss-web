class Operator < ActiveRecord::Base
  include Orderable
  include Userdelegator
  belongs_to :user
  has_many :shops
  attr_accessor :login
  
  enum state: {active: 0, disable: 1}
  validates :name, :mobile, presence: true
  validates :login, presence: true, on: :create
  before_validation :set_rates, on: :create
  before_create :binding_user, if: -> { user.blank? }
  after_create :active_user
  after_create :add_operator_role!

  def binding_user
    self.user = User.find_or_create_guest_with_session(login, {}) if login
  end

  def active_user
    Ubonus::Invite.delay.active_by_user_id(user_id)
  end

  def income(segment=:all)
    segment = :all if not %w(today month all).include?(segment)
    segment = :current_month if segment.to_s == "month"
    DivideIncome.where(user_id: user_id).send(segment).sum(:amount)
  end

  def total_income
    DivideIncome.where(target: self).sum(:amount)
  end

  def add_operator_role!
    user.add_role :operator
  end

  private
  def set_rates
    self.online_rate  = 0.5
    self.offline_rate = 0.05
  end
end
