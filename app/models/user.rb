class User < ActiveRecord::Base

  devise :database_authenticatable, :rememberable, :trackable, :validatable

  has_many :user_addresses
  has_many :orders
  has_one :user_info

  validates :login, uniqueness: true, mobile: true, presence: true
  validates :mobile, allow_nil: true, mobile: true

  alias_attribute :regist_mobile, :login

  delegate :sharing_counter, :income, :income_level_one, :income_level_two, :income_level_thr, to: :user_info, allow_nil: true

  # def user_info
  #   @user_info ||= super
  #   @user_info = create_user_info if @user_info.blank?
  #   @user_info
  # end

  def default_address
    @default_address ||= user_addresses.where(default: true).first
    @default_address ||= user_addresses.first
  end

  def self.create_guest_user(mobile)
    self.create(
      login: mobile,
      mobile: mobile, 
      password: 'ubossFakepa22w0rd', 
      need_reset_password: true)
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
end
