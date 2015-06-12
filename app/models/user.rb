class User < ActiveRecord::Base

  devise :database_authenticatable, :rememberable, :trackable, :validatable

  has_many :user_addresses
  has_many :orders

  validates :login, uniqueness: true, mobile: true, presence: true
  validates :mobile, allow_nil: true, mobile: true

  alias_attribute :regist_mobile, :login

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
end
