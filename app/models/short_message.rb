class ShortMessage
  def self.send_sms(phone,msg,tpl_id=1)
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
end