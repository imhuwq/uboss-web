class MobileAuthCode < ActiveRecord::Base
  validates :mobile,:presence=>true,:uniqueness=>true

  before_save :steps_before_save

  def steps_before_save
    generate_code
    set_expire_time
    send_code
  end

	def generate_code #生成验证码
    self.code = '%.5d' % rand(9999..100000)
  end

  def set_expire_time #设定过期时间
    self.expire_at = Time.now + 1.minute
  end

  def auth_code(code) #验证
    if code.to_s == self.code
      return true
    else
      return false
    end
  end

  def send_code #发送验证码
    #Messege.send(:mobile=>self.mobile,:message=>"您的验证码是：#{self.code}")
    return true
  end
end
