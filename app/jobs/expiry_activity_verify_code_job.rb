class ExpiryActivityVerifyCodeJob < ActiveJob::Base

  include Loggerable

  def perform
    VerifyCode.where('verified = false and activity_prize_id is not null').each do |obj|
      expiry_days = obj.activity_prize.activity_info.expiry_days
      if (obj.created_at + expriy_days) > Time.current
        obj.update(expired: true)
      end
    end
  end

end
