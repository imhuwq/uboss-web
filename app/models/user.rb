class User < ActiveRecord::Base

  devise :database_authenticatable, :rememberable, :trackable, :validatable

  has_many :user_addresses

  validates :login, uniqueness: true, mobile: true, presence: true
  validates :mobile, allow_nil: true, mobile: true

  alias_attribute :regist_mobile, :login

  def default_address
    user_addresses.first
  end

  private
    def email_required?
      false
    end
end
