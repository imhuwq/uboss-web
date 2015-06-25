class MobileAuthCode < ActiveRecord::Base
  validates :mobile,:presence=>true,:uniqueness=>true

  before_save :steps_before_save

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
    send_code
  end

	def generate_code #生成验证码
    self.code = '%.5d' % rand(9999..100000)
  end

  def set_expire_time #设定过期时间
    self.expire_at = Time.now + 30.minute
  end

  #FIXME 发送验证码,应该在创建成功之后
  def send_code
    #Messege.send(:mobile=>self.mobile,:message=>"您的验证码是：#{self.code}")
    return true
  end
end
