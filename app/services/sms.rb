module SMS
  extend self
  def send_sms(mobile, msg, tpl_id = 923_651) # 发送短信
    return { 'msg' => 'error', 'detail' => '电话号码不能为空' } if mobile.blank?
    return { 'msg' => 'error', 'detail' => '内容不能为空' } if msg.blank?
    sms = ChinaSMS.to(mobile, { code: msg }, tpl_id: tpl_id)
    sms['msg'] == 'OK' ? 'OK' : sms
  end
end
