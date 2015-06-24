class User < ActiveRecord::Base

  devise :database_authenticatable, :rememberable, :trackable, :validatable

  has_many :user_addresses
  has_many :orders
  has_many :sold_orders, class_name: 'Order', foreign_key: 'seller_id'
  has_one :user_info

  validates :login, uniqueness: true, mobile: true, presence: true
  validates :mobile, allow_nil: true, mobile: true

  alias_attribute :regist_mobile, :login

  delegate :sharing_counter, :income, :income_level_one, :income_level_two,
    :income_level_thr, :frozen_income,
    to: :user_info, allow_nil: true

  before_create :set_mobile

  class << self
    def new_guest(mobile)
      new(login: mobile, mobile: mobile, password: 'ubossFakepa22w0rd', need_reset_password: true)
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

  def user_info
    @user_info ||= super
    @user_info = create_user_info if @user_info.blank?
    @user_info
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
      self.mobile ||= login
    end
end
