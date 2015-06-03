#encoding:utf-8
class User < ActiveRecord::Base
  apply_simple_captcha
  devise :database_authenticatable, 
    # :registerable, 
    :omniauthable,
    :recoverable, 
    :rememberable, 
    :trackable, 
    :validatable

  MOBILE_REGEXP = /\A(\s*)(?:\(?[0\+]?\d{1,3}\)?)[\s-]?(?:0|\d{1,4})[\s-]?(?:(?:13\d{9})|(?:\d{7,8}))(\s*)\Z|\A[569][0-9]{7}\Z/

  validates :login, uniqueness: true, format: { with: MOBILE_REGEXP }
  validates :mobile, allow_nil: true, format: { with: MOBILE_REGEXP }

  private
    def email_required?
      false
    end
end
