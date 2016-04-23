class User < ActiveRecord::Base

  # FIXME 如果只是需要在页面转换请使用helper方法，或者I18n
  DATA_AUTHENTICATED = {'no'=> '未认证', 'yes'=> '已认证'}

  include Orderable
  include Sellerable

  attr_accessor :being_agency, :code, :mobile_auth_code
  OFFICIAL_ACCOUNT_LOGIN = '13800000000'.freeze

  devise :database_authenticatable, :rememberable, :trackable, :recoverable, :validatable, :confirmable,
    :async, :omniauthable, :registerable, authentication_keys: [:login_identifier]

  mount_uploader :avatar, ImageUploader

  has_and_belongs_to_many :expresses, uniq: true
  has_one :cart
  has_one :operator
  has_one :shop
  has_many :recommends
  has_many :user_infos, autosave: true
  has_many :verify_codes
  has_many :carriage_templates
  has_many :transactions
  has_many :user_role_relations, dependent: :destroy
  has_many :user_roles, through: :user_role_relations
  has_many :daily_reports
  has_many :sharing_nodes
  has_many :favour_products
  has_many :favoured_products, through: :favour_products, source: :product
  has_many :withdraw_records
  has_many :sended_mobile_captchas, class_name: 'MobileCaptcha', foreign_key: 'sender_id'
  has_many :activity_draw_records
  has_many :store_accounts, class_name: 'SubAccount', foreign_key: 'account_id'
  # for agent
  has_many :divide_incomes
  has_many :sellers, class_name: 'User', foreign_key: 'agent_id'
  has_many :seller_ordinary_orders, through: :sellers, source: :sold_ordinary_orders
  has_many :seller_service_orders,  through: :sellers, source: :sold_service_orders
  # for buyer
  has_one :cart
  has_one :ordinary_store, class_name: 'OrdinaryStore', autosave: true, validate: false
  has_one :service_store, class_name: 'ServiceStore', autosave: true, validate: false
  has_many :user_addresses, -> { where(seller_address: false) }
  has_many :orders
  has_many :ordinary_orders
  has_many :service_orders
  has_many :dishes_orders
  has_many :order_charges
  has_many :order_items
  has_many :sharing_incomes
  has_many :bank_cards
  has_many :privilege_cards
  has_many :refund_messages
  has_many :order_item_refunds
  has_many :sales_returns, through: :order_item_refunds
  has_many :carriage_templates
  has_many :bonus_records
  has_many :bill_orders
  # for seller
  has_many :seller_addresses, -> { where(seller_address: true) }, class_name: 'UserAddress'
  has_many :sold_orders, class_name: 'Order', foreign_key: 'seller_id'
  has_many :sold_ordinary_orders, class_name: 'OrdinaryOrder', foreign_key: 'seller_id'
  has_many :sold_service_orders,  class_name: 'ServiceOrder',  foreign_key: 'seller_id'
  has_many :products
  has_many :ordinary_products
  has_many :service_products
  has_many :sold_ordinary_order_items, through: :sold_ordinary_orders, source: :order_items
  has_many :categories
  has_many :selling_incomes
  has_many :sub_accounts
  has_many :calling_services
  has_many :calling_notifies
  has_many :table_numbers
  belongs_to :agent, class_name: 'User'
  has_many :promotion_activities
  has_many :sold_bill_orders, class_name: 'BillOrder', foreign_key: :seller_id
  #for supplier
  has_one :supplier_store, autosave: true
  has_many :cooperations, foreign_key: 'supplier_id', dependent: :destroy
  has_many :agencies, through: :cooperations, source: :agency
  has_many :supplier_products, ->{ where(type: 'SupplierProduct') }
  has_many :the_agency_products, ->{ where(type: 'AgencyProduct') }, foreign_key: 'supplier_id', class_name: 'AgencyProduct' do
    def with(agency)
      where(user_id: agency.id)
    end
  end
  has_many :send_captcha_histories, ->{ where(invite_type: 1) }, foreign_key: 'sender_id', class_name: 'CaptchaSendingHistory'

  #for agency
  has_many :reverse_cooperations, foreign_key: 'agency_id', class_name: 'Cooperation', dependent: :destroy
  has_many :suppliers, through: :reverse_cooperations, source: :supplier
  has_many :agency_products, ->{ where(type: 'AgencyProduct') }
  has_many :receive_captcha_histories, ->{ where(invite_type: 1) }, foreign_key: 'receiver_id', class_name: 'CaptchaSendingHistory'


  validates :login, uniqueness: true, mobile: true, allow_blank: true
  validates_presence_of :login, presence: true, if: -> { email.blank? }
  validates_presence_of :email, presence: true, if: -> { login.blank? }
  validates :mobile, allow_nil: true, mobile: true
  validates :agent_code, uniqueness: true, allow_nil: true
  validates :authentication_token, uniqueness: true, presence: true
  validates_numericality_of :privilege_rate,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 100, only_integer: true

  alias_attribute :regist_mobile, :login

  delegate :sex, :sex=, :province, :province=, :city, :city=, :country, :country=,
    :good_evaluation, :best_evaluation, :better_evaluation, :worst_evaluation, :bad_evaluation,
    :store_name, :store_name=,      :income_level_thr, :frozen_income,
    :income,     :income_level_one, :income_level_two, :service_rate, :type, :type=,
    :store_banner_one_identifier,  :store_banner_two_identifier,  :store_banner_thr_identifier,
    :store_banner_one,  :store_banner_two,  :store_banner_thr,
    :store_banner_one_url,  :store_banner_two_url,  :store_banner_thr_url,
    :store_banner_one=, :store_banner_two=, :store_banner_thr=,
    :recommend_resource_one_id, :recommend_resource_two_id, :recommend_resource_thr_id,
    :recommend_resource_one_id=, :recommend_resource_two_id=, :recommend_resource_thr_id=,
    :store_short_description, :store_short_description=, :store_cover, :store_cover=, :bonus_benefit, :bonus_benefit=,
    :store_title, :store_identify,
    :good_reputation_rate, :total_reputations,
    :platform_service_rate, :agent_service_rate,
    to: :ordinary_store, allow_nil: true

  enum authenticated: {no: 0, yes: 1}

  before_destroy do # prevent destroy official account
    false if login == OFFICIAL_ACCOUNT_LOGIN
  end
  before_update do
    false if login == OFFICIAL_ACCOUNT_LOGIN && changes.include?(:login)
  end
  before_validation :ensure_authentication_token, :ensure_privilege_rate
  before_create :set_mobile, :set_default_role
  before_create :build_ordinary_store, if: -> { ordinary_store.blank? }
  before_create :build_service_store, if: -> { service_store.blank? }
  before_create :skip_confirmation!
  before_save   :set_service_rate
  after_commit  :invoke_rongcloud_job, on: [:create, :update]
  after_commit :invoke_bill_order_attach_job, on: [:create, :update], if: -> {
    weixin_openid.present? && previous_changes.include?(:weixin_openid)
  }

  scope :admin, -> { where(admin: true) }
  scope :agent, -> { role('agent') }
  scope :role,  -> (role_name) { joins(:user_roles).where(user_roles: {name: role_name}) }
  scope :unauthenticated_seller_identify, -> { where(authenticated: 0) }

  UserRole::ROLE_NAMES.each do |role|
    class_eval <<-RUBY, __FILE__, __LINE__+1
      def is_#{role}?
        @is_#{role} ||= user_roles.exists?(name: '#{role}')
      end
    RUBY
  end

  def recommended_products
    Product.joins('INNER JOIN recommends ON products.id = recommends.recommended_id').
      where('recommends.user_id = :user_id AND recommends.recommended_type IN (:product_types)', user_id: id, product_types: ['ServiceProduct', 'OrdinaryProduct', 'AgencyProduct'])
  end

  def has_privilege_card?(object)
    seller_ids = self.privilege_cards.map(&:seller_id)
    seller_ids.include?(object.user_id)
  end

  def has_promotion_activity?
    return @has_promotion_activity if instance_variable_defined?('@has_promotion_activity')
    @has_promotion_activity = PromotionActivity.where(user: self, status: 1).exists?
  end

  def has_store_account?
    return @has_store_account if instance_variable_defined?('@has_store_account')
    @has_store_account = store_accounts.active.exists?
  end

  def service_store
    super || build_service_store
  end

  def ordinary_store
    super || build_ordinary_store
  end

  def has_recommend?(object)
    Recommend.where(user_id: self.id, recommended_id: object.id, recommended_type: object.class).exists?
  end

  def login_identifier=(login_identifier)
    @login_identifier = login_identifier
  end

  def login_identifier
    @login_identifier || self.login || self.email
  end

  def image_url(version = nil)
    avatar.url(version)
  end

  def crypt_id
    self.id && CryptService.encrypt(self.id)
  end

  def received_invite_bonus?
    bonus_records.where(type: 'Ubonus::Invite').exists?
  end

  def has_role?(role_name)
    user_roles.any? { |role| role.name == role_name.to_s }
  end

  def remove_role(role_name)
    if role=UserRole.find_by_name(role_name)
      user_roles.delete role
    else
      false
    end
  end

  def add_role(role_name)
    return true if have_role?(role_name)
    if role=UserRole.find_by_name(role_name)
      user_roles << role
    else
      false
    end
  end

  def have_role?(role_name)
    user_roles.exists?(name: role_name)
  end

  def published_activity
    promotion_activities.find_by(status: 1)
  end

  class << self

    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login_identifier = conditions.delete(:login_identifier)
        where(conditions.to_h).
          where(["lower(login) = :value OR lower(email) = :value", { value: login_identifier.downcase }]).first
      else
        where(conditions.to_h).first
      end
    end

    def official_account
      @official_account ||= find_by(login: OFFICIAL_ACCOUNT_LOGIN)
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

    def find_or_create_guest(mobile)
      user = User.find_by(login: mobile)
      unless user.present?
        user = new_guest(mobile)
        user.save
      end
      user
    end

    def create_guest!(mobile)
      new_user = new_guest(mobile)
      new_user.save!
      new_user
    end

    def find_or_create_guest_with_session(mobile, session)
      user = find_by(login: mobile)
      user ||= new_guest(mobile)
      user.update_with_oauth_session(session)
      user.save if !user.persisted?
      user
    end

    def new_with_session(params, session)
      super.tap do |user|
        get_valuable_session(session) do |data|
          user.set_wechat_data(data)
        end
      end
    end

    def get_valuable_session(session)
      if data = session["devise.wechat_data"] && session["devise.wechat_data"]["extra"]["raw_info"]
        yield data if block_given?
      end
    end

  end

  def invoke_bill_order_attach_job
    BillOrderAttachJob.perform_later(user: self)
  end

  def invoke_rongcloud_job
    if rongcloud_token.blank? || [:nickname, :avatar].any? { |key| previous_changes.include?(key) }
      RongcloudJob.perform_later(user: self, type: 'user_info')
    end
  end

  # 默认绑定official agent
  def bind_agent(binding_code = nil)
    agent_user = if binding_code.present?
                   User.agent.find_by(agent_code: binding_code) || AgentInviteSellerHistroy.find_by(invite_code: binding_code).try(:agent)
                 else
                   User.official_account
                 end

    if agent_user.blank?
      errors.add(:agent_code, :invalid)
      return false
    end
    if self.can_rebind_agent?
      self.agent = agent_user
      self.admin = true
      self.user_info.service_rate = 5
      self.user_roles << UserRole.seller if not self.is_seller?
      self.save
    else
      false
    end
  end

  def can_rebind_agent? # 检查绑定条件
    if !self.agent.present? # 如果没有绑定,许可
      return true
    else
      if self.agent.is_super_admin? && !self.authenticated? # 如果绑定对象是超级管理员,且还没有通过认证,许可
        return true
      else # 其他情况不能更换绑定
        self.errors[:base] << "操作失败，已绑定非官方创客，或已认证"
        return false
      end
    end
  end

  def bind_seller(seller)
    seller.agent = self
    seller.admin = true
    seller.user_roles << UserRole.seller if !seller.is_seller?
    seller.save
  end

  def update_with_oauth_session(session)
    self.class.get_valuable_session(session) do |data|
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

  def identify
    nickname.presence || mobile.presence || 'UBOSS用户'
  end

  def total_income
    income + frozen_income
  end

  def total_divide_income
    divide_incomes.sum(:amount)
  end

  def total_divide_income_from_seller(seller)
    divide_incomes.joins(:order).where(orders: { seller_id: seller.id }).sum(:amount)
  end

  def crrent_month_divide_income_from_seller(seller)
    divide_incomes.current_month.joins(:order).where(orders: { seller_id: seller.id }).sum(:amount)
  end

  def today_divide_income_from_seller(seller)
    divide_incomes.today.joins(:order).where(orders: { seller_id: seller.id }).sum(:amount)
  end

  def total_sold_income
    selling_incomes.sum(:amount)
  end

  def current_month_sold_income
    selling_incomes.current_month.sum(:amount)
  end

  def today_sold_income
    selling_incomes.today.sum(:amount)
  end

  def today_expect_divide_income
    seller_ordinary_orders.today.shiped.sum(:pay_amount) * 0.05
  end

  def current_month_divide_income
    divide_incomes.current_month.sum(:amount)
  end

  def current_year_divide_income
    divide_incomes.current_year.sum(:amount)
  end

  def user_info
    ordinary_store
  end

  def default_address
    @default_address ||= user_addresses.where(default: true, seller_address: false).first
    @default_address ||= user_addresses.where(seller_address: false).first
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
    role_names.include?(role_name.to_s)
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

  def sellers
    User.where(agent_id: self.id)
  end

  def authenticated?
    self.authenticated == 'yes'
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
      agent_code
    else
      generate_agent_code
      self.agent_code
    end
  end

  def set_wechat_data(data)
    self.nickname       ||= data["nickname"]
    self.sex            ||= data["sex"]
    self.province       ||= data['province']
    self.city           ||= data['city']
    self.country        ||= data['country']
    self.weixin_unionid   = data['unionid']
    self.weixin_openid    = data['openid']
    self.remote_avatar_url = data['headimgurl'] if self.avatar_identifier.blank?
  end

  def has_seller_privilege_card?(seller)
    privilege_cards.where(seller_id: seller.id).exists?
  end

  def favour_product(product)
    favour_products.create(product_id: product.id)
  end

  def unfavour_product(product)
    favour_products.where(product_id: product.id).delete_all
  end

  def is_comman_express?(express)
    self.expresses.exists?(express)
  end

  def default_post_address
    @default_post_address ||= seller_addresses.find_by('usage @> ?', {default_post_address: 'true'}.to_json)
  end

  def default_get_address
    @default_get_address ||= seller_addresses.find_by('usage @> ?', {default_get_address: 'true'}.to_json)
  end

  def find_or_create_rongcloud_token
    return rongcloud_token if rongcloud_token.present?

    user = Rongcloud::Service::User.new
    user.user_id = self.id
    user.name = self.identify
    user.portrait_uri = self.avatar.url(:thumb)
    user.get_token
    self.update_columns(rongcloud_token: user.token)
    user.token
  end

  def has_cooperation_with_agency?(user)
    cooperations.find_by_agency_id(user.id)
  end

  def has_cooperation_with_supplier?(user)
    reverse_cooperations.find_by_supplier_id(user.id)
  end

  def has_supplier_store?
    SupplierStore.exists?(user_id: self.id)
  end

  private

  def ensure_privilege_rate
    self.privilege_rate = self.privilege_rate.to_i
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
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

  def set_default_role
    if !self.is_agent?
      self.admin = true
      self.user_roles << UserRole.agent
    end
  end

  def set_service_rate
    if self.agent_id_changed? && user_info.present?
        user_info.platform_service_rate = 25
        user_info.agent_service_rate = 25
    end
  end

end
