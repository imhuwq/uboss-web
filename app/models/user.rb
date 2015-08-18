class User < ActiveRecord::Base
  DATA_AUTHENTICATED = {'no'=> '未认证', 'yes'=> '已认证'}

  include Orderable

  attr_accessor :code, :mobile_auth_code
  OFFICIAL_ACCOUNT_LOGIN = '13800000000'

  devise :database_authenticatable, :rememberable, :trackable, :validatable,
    :omniauthable, :registerable

  mount_uploader :avatar, ImageUploader

  has_one :user_info, autosave: true
  has_many :transactions
  has_many :user_role_relations, dependent: :destroy
  has_many :user_roles, through: :user_role_relations
  # for agent
  has_many :divide_incomes
  # for buyer
  has_many :user_addresses
  has_many :orders
  has_many :sharing_incomes
  has_many :bank_cards
  has_many :privilege_cards
  # for seller
  has_many :sold_orders, class_name: 'Order', foreign_key: 'seller_id'
  has_many :products
  belongs_to :agent, class_name: 'User'

  validates :login, uniqueness: true, mobile: true, presence: true, if: -> { !need_set_login? }
  validates :mobile, allow_nil: true, mobile: true
  validates :agent_code, uniqueness: true, allow_nil: true

  alias_attribute :regist_mobile, :login

  delegate :sex, :sex=, :province, :province=, :city, :city=, :country, :country=,
    :store_name, :store_name=, to: :user_info, allow_nil: true
  delegate :income, :income_level_one, :income_level_two, :service_rate,
    :income_level_thr, :frozen_income,
    to: :user_info, allow_nil: true

  enum authenticated: {no: 0, yes: 1}

  before_destroy do # prevent destroy official account
    if login == OFFICIAL_ACCOUNT_LOGIN
      false
    end
  end
  before_create :set_mobile
  before_create :build_user_info, if: -> { user_info.blank? }

  scope :admin, -> { where(admin: true) }

  UserRole::ROLE_NAMES.each do |role|
    User.class_eval do
      define_method "is_#{role}?" do
        user_roles.exists?(name: role)
      end
    end
  end

  class << self
    def official_account
      @@official_account ||= find_by(login: OFFICIAL_ACCOUNT_LOGIN)
    end

    def find_or_update_by_wechat_oauth(oauth_info)
      user = User.find_by(weixin_openid: oauth_info['openid'])
      if user.present?
        user.update_with_wechat_oauth(oauth_info)
      end
      user
    end

    def new_guest(mobile)
      new(login: mobile, mobile: mobile, password: Devise.friendly_token, need_reset_password: true)
    end

    def create_guest(mobile)
      new_user = new_guest(mobile)
      new_user.save
      new_user
    end

    def create_guest!(mobile)
      new_user = new_guest(mobile)
      new_user.save!
      new_user
    end

    def find_or_create_guest_with_session(mobile, session)
      user = find_by(login: mobile)
      user ||= create_guest(mobile)
      user.update_with_oauth_session(session)
      user
    end

    def new_with_session(params, session)
      super.tap do |user|
        get_valuable_session(session) do |data|
          user.set_wechat_data(data)
        end
      end
    end

  end

  def bind_agent(binding_code)
    agent_user = User.agent.find_by(agent_code: binding_code)
    if agent_user.present?
      self.agent = agent_user
      self.become_uboss_seller
      self.save
    else
      errors.add(:code, :invalid)
      false
    end
  end

  def update_with_oauth_session(session)
    get_valuable_session(session) do |data|
      set_wechat_data(data)
      save
    end
  end

  def update_with_wechat_oauth(oauth_info)
    self.tap do
      set_wechat_data(oauth_info)
      if avatar_url.present?
        self.remote_avatar_url = nil
      end
      save
    end
  end

  def become_uboss_seller
    if not self.is_seller?
      transaction do
        update_columns(admin: true)
        user_roles << UserRole.seller
      end
    end
  end

  def identify
    nickname || regist_mobile
  end

  def store_identify
    store_name || nickname || regist_mobile
  end

  def total_income
    income + frozen_income
  end

  def user_info
    super || build_user_info
  end

  def default_address
    @default_address ||= user_addresses.where(default: true).first
    @default_address ||= user_addresses.first
  end

  def set_default_address(address = nil)
    address ||= user_addresses.first
    user_addresses.where(default: true).update_all(default: false)
    address.update(default: true)
  end

  def role_names
    @role_names ||= user_roles.pluck(:name)
  end

  def is_role?(role_name)
    role_names.include?(role_name)
  end

  def seller_today_joins
    User.where("agent_id = ? and created_at > ? and created_at < ?", self.id, Time.now.beginning_of_day, Time.now.end_of_day)
  end

  def seller_total_joins
    User.where("agent_id = ?", self.id)
  end

  def self.agent_today_joins
    UserRole.find_by(name: "agent").users.where("created_at > ? and created_at < ?", Time.now.beginning_of_day, Time.now.end_of_day)
  end

  def self.agent_total_joins
    UserRole.find_by(name: "agent").users
  end

  def seller
    User.where(agent_id: self.id)
  end

  def seller?
    user_roles.collect(&:name).include?('seller')
  end

  def agent?
    user_roles.collect(&:name).include?('agent')
  end
  def super_admin?
    user_roles.collect(&:name).include?('super_admin')
  end

  def authenticated?
    if self.authenticated == 'yes'
      return true
    else
      return false
    end
  end

  def generate_agent_code
    loop do
      self.agent_code = rand(9999..100000).to_s.ljust(6,'0')
      break if !User.find_by(agent_code: agent_code)
    end
    save
  end

  def find_or_create_agent_code
    if agent_code.present?
      return agent_code
    else
      generate_agent_code
      return self.agent_code
    end
  end

  def binding_agent(code)
    if code.present?
      agent = User.find_by(agent_code: code)
    else
      agent = User.joins(:user_roles).where(user_roles:{name: 'super_admin'}).first
    end
    self.agent_id = agent.id
    self.admin = true
    self.save
    AgentInviteSellerHistroy.find_by(mobile: login).try(:update, status: 1)
  end

  private

  def set_wechat_data(data)
    self.nickname       ||= data["nickname"]
    self.sex            ||= data["sex"]
    self.province       ||= data['province']
    self.city           ||= data['city']
    self.country        ||= data['country']
    self.weixin_unionid   = data['unionid']
    self.weixin_openid    = data['openid']
    self.remote_avatar_url = data['headimgurl']
  end

  def get_valuable_session(session)
    if data = session["devise.wechat_data"] && session["devise.wechat_data"]["extra"]["raw_info"]
      yield data if block_given?
    end
  end

  def email_required?
    false
  end

  def set_mobile
    if !need_set_login?
      self.mobile ||= login
    end
  end
end
