class MobileAuthCode < ActiveRecord::Base
  validates :mobile,:presence=>true,:uniqueness=>true

  before_save :steps_before_save
  after_save :send_code

  def self.auth_code(mobile, code) #验证
    auth_code = MobileAuthCode.
      where('expire_at > ?', Time.now).
      find_by(mobile: mobile, code: code)

    if auth_code.blank?
      false
    else
      true
    end
  end

  def steps_before_save
    generate_code
    set_expire_time
  end

	def generate_code #生成验证码
    self.code = '%.5d' % rand(9999..100000)
  end

  def set_expire_time #设定过期时间
    self.expire_at = Time.now + 30.minute
  end

  def send_sms(phone,msg,tpl_id=1) # 发送短信
    raise "send sms : phone is blank." if phone.blank?
    raise "send sms : msg is blank." if msg.blank?
    begin
      sms = ChinaSMS.to(phone, {code:msg,company:'优来吧UBoss'}, tpl_id: tpl_id)
      return "OK" if sms['msg'] == "OK"
      return sms
    rescue Exception => e
      return e.message
    end
  end

  def send_code # 发送验证码
    sms = send_sms(self.mobile,self.code)
    if sms == "OK"
      return true
    else
      raise sms
    end
  end
end
