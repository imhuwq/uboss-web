class Operator < ActiveRecord::Base
  include Orderable
  include Userdelegator
  belongs_to :user
  has_many :shops
  attr_accessor :login
  
  enum state: {active: 0, disable: 1}
  validates :name, :mobile, presence: true
  validates :login, presence: true, on: :create
  before_create :binding_user, if: -> { user.blank? }
  after_create :active_user
  after_create :add_operator_role!

  def binding_user
    self.user ||= User.find_or_create_guest_with_session(login, {})
  end

  def active_user
    Ubonus::Invite.delay.active_by_user_id(user_id)
  end

  def add_operator_role!
    user.add_role :operator
  end
end
