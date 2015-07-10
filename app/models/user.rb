class User < ActiveRecord::Base

  include Orderable

  devise :database_authenticatable, :rememberable, :trackable, :validatable, :omniauthable
  mount_uploader :avatar, ImageUploader

  has_one :user_info, autosave: true
  has_many :user_addresses
  has_many :orders
  has_many :sold_orders, class_name: 'Order', foreign_key: 'seller_id'
  has_many :sharing_incomes
  has_many :bank_cards
  belongs_to :user_role

  validates :login, uniqueness: true, mobile: true, presence: true, if: -> { !need_set_login? }
  validates :mobile, allow_nil: true, mobile: true

  alias_attribute :regist_mobile, :login

  delegate :sex, :sex=, :province, :province=, :city, :city=, :country, :country=,
    :store_name, :store_name=, to: :user_info, allow_nil: true
  delegate :sharing_counter, :income, :income_level_one, :income_level_two,
    :income_level_thr, :frozen_income,
    to: :user_info, allow_nil: true
  delegate :name, :display_name, to: :user_role, prefix: :role, allow_nil: true

  before_create :set_mobile

  scope :admin, -> { where(admin: true) }

  class << self
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

  def user_info
    super || build_user_info
  end

  def find_or_create_user_info
    if user_info.new_record?
      user_info.save
    end
    user_info
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
