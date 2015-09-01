class MobileAuthCode < ActiveRecord::Base
  validates :mobile, presence: true, uniqueness: true, mobile: true
  validates :code, :expire_at, presence: true

  before_validation :generate_code, :set_expire_time
  before_save :send_code

  def self.auth_code(auth_mobile, auth_code) #验证
    MobileAuthCode.where('expire_at < ?', DateTime.now).delete_all
    MobileAuthCode.exists?(mobile: auth_mobile, code: auth_code)
  end

  def self.send_captcha_with_mobile(auth_mobile)
    auth_code = MobileAuthCode.find_or_initialize_by(mobile: auth_mobile)
    auth_code.regenerate_code unless auth_code.new_record?
    { success: auth_code.save, mobile_auth_code: auth_code }
  end

  def self.clear_captcha(auth_mobile)
    MobileAuthCode.where(mobile: auth_mobile).delete_all
  end

	def generate_code #生成验证码
    self.code ||= rand(9999..100_000).to_s.ljust(5, '0')
  end

  def set_expire_time # 设定过期时间
    self.expire_at ||= DateTime.now + 30.minute
  end

	def regenerate_code
    self.tap do |mobile_auth_code|
      mobile_auth_code.code = rand(9999..100_000).to_s.ljust(5,'0')
      mobile_auth_code.expire_at = DateTime.now + 30.minute
    end
  end

  def send_sms(tpl_id = 1) # 发送短信
    PostMan.send_sms(mobile, code, tpl_id)
  end

  def send_code # 发送验证码
    result = send_sms
    errors.add(:code, result[:message]) if not result[:success]
    result[:success]
  end
end
