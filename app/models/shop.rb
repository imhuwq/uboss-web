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
    content = "恭喜您，成功开通UBOSS账号。您的账号信息如下，账号名：#{login}，登陆密码：#{default_passwd}，登陆地址：http://www.uboss.cn，请勿泄露。关注“UBOSS星球”公众号，获取更多使用教程。您的业务员姓名是：#{clerk_name}，电话号码：#{clerk_mobile}，有问题可随时咨询，感谢您的使用！"
    SmsJob.perform_later(mobile, content)
  end
end
