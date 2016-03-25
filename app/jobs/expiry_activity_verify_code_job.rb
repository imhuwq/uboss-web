class ExpiryActivityVerifyCodeJob < ActiveJob::Base
  include Loggerable

  def perform
    logger.info("START:ExpiryActivityVerifyCodeJob")
    VerifyCode.where('verified = false and activity_prize_id is not null').each do |obj|
      expiry_days = obj.activity_prize.activity_info.expiry_days
      if (obj.created_at + expriy_days) > Time.current
        obj.update(expired: true)
        logger.info("updated #{obj.class}: {id: #{obj.id}, expired: true}")
      end
    end
    logger.info("DONE:ExpiryActivityVerifyCodeJob")
  end

end
