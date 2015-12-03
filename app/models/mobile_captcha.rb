class MobileCaptcha < ActiveRecord::Base

  CAPTCHA_TYPES = %w(invite_seller)

  validates :mobile, presence: true, uniqueness: { scope: :captcha_type }, mobile: true
  validates :code, :expire_at, presence: true
  validates :captcha_type, inclusion: { in: CAPTCHA_TYPES }, allow_nil: true

  before_validation :generate_code, :set_expire_time
  before_save :send_code

  def self.auth_code(auth_mobile, auth_code, type = nil)
    MobileCaptcha.where('expire_at < ?', DateTime.now).delete_all
    MobileCaptcha.exists?(
      mobile: auth_mobile,
      code: auth_code,
      captcha_type: type
    )
  end

  def self.send_captcha_with_mobile(auth_mobile, type = nil)
    auth_code = MobileCaptcha.find_or_initialize_by(
      mobile: auth_mobile,
      captcha_type: type
    )
    auth_code.regenerate_code unless auth_code.new_record?
    { success: auth_code.save, mobile_auth_code: auth_code }
  end

  def self.clear_captcha(auth_mobile)
    MobileCaptcha.where(mobile: auth_mobile).delete_all
  end

	def generate_code #生成验证码
    self.code ||= rand_code
  end

  def set_expire_time # 设定过期时间
    self.expire_at ||= DateTime.now + 30.minute
  end

	def regenerate_code
    self.tap do |mobile_auth_code|
      mobile_auth_code.code = rand_code
      mobile_auth_code.expire_at = DateTime.now + 30.minute
    end
  end

  def send_sms(tpl_id = 1126529) # 发送短信
    PostMan.send_sms(mobile, {code: code}, tpl_id)
  end

  def send_code # 发送验证码
    result = send_sms
    errors.add(:code, result[:message]) if not result[:success]
    result[:success]
  end

  private
  def rand_code
    prand(100_000).to_s.ljust(5,'0')
  end
end
