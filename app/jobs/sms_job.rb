class SmsJob < ActiveJob::Base

  queue_as :sms

  def perform(login, content)
    PostMan.send_sms(login, content)
  end

end
