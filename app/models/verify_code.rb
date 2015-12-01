class VerifyCode < ActiveRecord::Base
  validates_uniqueness_of :code

  def generate_code
    self.code = SecureRandom.random_number(100000000000)
  end

  def verify_code
    update(verified: true) if !verified
  end
end
