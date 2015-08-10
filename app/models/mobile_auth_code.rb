class MobileAuthCode < ActiveRecord::Base

  validates :mobile, presence: true, uniqueness: true, mobile: true
  validates :code, :expire_at, presence: true

  before_validation :generate_code, :set_expire_time
  after_save :send_code

  def self.auth_code(auth_mobile, auth_code) #验证
    mobile_auth_code = MobileAuthCode.
      where('expire_at > ?', Time.now).
      find_by(mobile: auth_mobile, code: auth_code)

    if mobile_auth_code.blank?
      false
    else
      mobile_auth_code.destroy
      true
    end
  end

  def self.send_captcha_with_mobile(auth_mobile)
    auth_code = MobileAuthCode.find_or_initialize_by(mobile: auth_mobile)
    auth_code.regenerate_code unless auth_code.new_record?
    auth_code.save
  end

	def generate_code #生成验证码
    self.code ||= rand(9999..100000).to_s.ljust(5,'0')
  end

  def set_expire_time #设定过期时间
    self.expire_at ||= Time.now + 30.minute
  end

	def regenerate_code
    self.tap do |mobile_auth_code|
      mobile_auth_code.code = rand(9999..100000).to_s.ljust(5,'0')
      mobile_auth_code.expire_at = Time.now + 30.minute
    end
  end

  def send_sms(tpl_id=1) # 发送短信
    return {'msg'=> 'error',"detail"=>"电话号码不能为空"} if mobile.blank?
    return {'msg'=> 'error',"detail"=>"内容不能为空"} if code.blank?
    begin
      sms = ChinaSMS.to(mobile, {code:code,company:'优来吧UBoss'}, tpl_id: tpl_id)
      return "OK" if sms['msg'] == "OK"
      return sms
    rescue => e
      Airbrake.notify_or_ignore(e, parameters: {mobile: mobile, code: code}, cgi_data: ENV.to_hash)
      return e.message
    end
  end

  def send_code # 发送验证码
    result = send_sms
    if result == "OK"
      return true
    else
      raise result
    end
  end
end
