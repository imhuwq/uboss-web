class SmsJob < ActiveJob::Base

  queue_as :sms

  def perform(login, content, tpl=nil)
    PostMan.send_sms(login, content, tpl)
  end

end
