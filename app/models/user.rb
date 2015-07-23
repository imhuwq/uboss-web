class User < ActiveRecord::Base

  include Orderable

  attr_accessor :code
  OFFICIAL_ACCOUNT_LOGIN = '13800000000'

  devise :database_authenticatable, :rememberable, :trackable, :validatable, :omniauthable
  mount_uploader :avatar, ImageUploader

  has_one :user_info, autosave: true
  has_many :transactions
  # for buyer
  has_many :user_addresses
  has_many :orders
  has_many :sharing_incomes
  has_many :bank_cards
  has_many :privilege_cards
  # for seller
  has_many :sold_orders, class_name: 'Order', foreign_key: 'seller_id'
  has_many :products
  has_many :user_role_relations, dependent: :destroy
  has_many :user_roles, through: :user_role_relations
  belongs_to :agent, class_name: 'User'

  validates :login, uniqueness: true, mobile: true, presence: true, if: -> { !need_set_login? }
  validates :mobile, allow_nil: true, mobile: true

  alias_attribute :regist_mobile, :login

  delegate :sex, :sex=, :province, :province=, :city, :city=, :country, :country=,
    :store_name, :store_name=, to: :user_info, allow_nil: true
  delegate :income, :income_level_one, :income_level_two, :service_rate,
    :income_level_thr, :frozen_income,
    to: :user_info, allow_nil: true

  before_destroy do # prevent destroy official account
    if login == OFFICIAL_ACCOUNT_LOGIN
      false
    end
  end
  before_create :set_mobile
  before_create :build_user_info, if: -> { user_info.blank? }

  scope :admin, -> { where(admin: true) }

  class << self
    def official_account
      @@official_account ||= find_by(login: OFFICIAL_ACCOUNT_LOGIN)
    end

    def find_or_create_by_wechat_oauth(oauth_info)
      user = User.find_by(weixin_openid: oauth_info['openid'])
      if user
        user.update_with_wechat_oauth(oauth_info)
        user
      else
        User.create!(
          weixin_openid: oauth_info['openid'],
          weixin_unionid: oauth_info['unionid'],
          login: oauth_info['openid'],
          password: Devise.friendly_token,
          province: oauth_info['province'],
          city: oauth_info["city"],
          country: oauth_info['country'],
          nickname: oauth_info['nickname'],
          sex: oauth_info['sex'],
          remote_avatar_url: oauth_info['headimgurl'],
          need_set_login: true,
          need_reset_password: true
        )
      end
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
  end

  def update_with_wechat_oauth(oauth_info)
    info = {
      nickname: nickname || oauth_info['nickname'],
      sex: sex || oauth_info['sex'],
      province: province || oauth_info['province'],
      city: city || oauth_info['city'],
      country: country || oauth_info['country'],
      weixin_unionid: oauth_info['unionid'],
      weixin_openid: oauth_info['openid']
    }
    if avatar.blank?
      info.merge(remote_avatar_url: oauth_info['headimgurl'])
    end
    update(info)
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
    User.where("agent_id = ? and created_at > ? and created_at < ?", self.id, Time.now.beginning_of_day, Time.now.end_of_day).count
  end

  def seller_total_joins
    User.where("agent_id = ?", self.id).count
  end

  def self.agent_today_joins
    UserRole.find_by(name: "agent").users.where("created_at > ? and created_at < ?", Time.now.beginning_of_day, Time.now.end_of_day).count
  end

  def self.agent_total_joins
    UserRole.find_by(name: "agent").users.count
  end

  def seller
    User.where(agent_id: self.id)
  end

  private
    def email_required?
      false
    end

    def set_mobile
      if !need_set_login?
        self.mobile ||= login
      end
    end
end
