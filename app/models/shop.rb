class Shop < ActiveRecord::Base
  include Orderable
  include Userdelegator
  include Imagable
  belongs_to :user
  belongs_to :operator
  belongs_to :clerk
  has_many :online_orders, class_name: 'Order', foreign_key: :seller_id, primary_key: :user_id
  has_many :offline_orders, class_name: 'BillOrder', foreign_key: :seller_id, primary_key: :user_id
  has_one_image autosave: true
  delegate :image_url, to: :asset_img, allow_nil: true
  delegate :avatar=, :avatar, to: :asset_img, allow_nil: true
  delegate :mobile, :name, to: :clerk, allow_nil: true, prefix: true
  scope :online_turnovers, -> (segment=:today){ joins(:online_orders).merge(Order.have_paid.send(segment)).sum("orders.paid_amount") }
  scope :offline_turnovers, -> (segment=:today){ joins(:offline_orders).merge(BillOrder.payed.send(segment)).sum("bill_orders.paid_amount") }

  attr_accessor :login

  validates :operator_id, :province, :city, :district, :mobile, :name, :address, presence: true
  validates :mobile, numericality: true, :length => { minimum: 11, maximum: 11 }
  before_validation :set_login, if: -> { !!login }
  before_create :binding_user, if: -> { user.blank? }
  after_create :active_user
  after_commit :send_sms, on: :create
  after_save :save_clerk!

  def binding_user
    user = User.find_or_initialize_by(login: login)
    if user.new_record?
      user.mobile   = mobile
      user.password = default_passwd
      user.save(validate: false)
    end
    self.user = user
  end

  def active_user
    Ubonus::Invite.delay.active_by_user_id(user_id)
  end

  def online_turnovers(segment=:all)
    self.class.where(id: id).online_turnovers(segment)
  end

  def offline_turnovers(segment=:all)
    self.class.where(id: id).offline_turnovers(segment)
  end

  def clerk=(c)
    if c.is_a?(Hash)
      super Clerk.find_or_initialize_by({mobile: c[:mobile]}).tap {|clerk| clerk.name = c[:name] }
    else
      super
    end
  end

  def save_clerk!
    clerk.changed? && clerk.save!
  end

  def default_passwd
    mobile.to_s.last(4)
  end

  def set_login
    self.login = self.mobile if login.blank?
  end

  def send_sms
    SmsJob.perform_later(mobile, {login: login, passwd: default_passwd, clerk_name: clerk_name, clerk_mobile: clerk_name })
  end
end
