class User < ActiveRecord::Base

  devise :database_authenticatable, :rememberable, :trackable, :validatable

  validates :login, uniqueness: true, mobile: true
  validates :mobile, allow_nil: true, mobile: true

  private
    def email_required?
      false
    end
end
