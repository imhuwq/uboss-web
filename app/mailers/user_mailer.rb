class UserMailer < Devise::Mailer

  default from: "support@ulaiber.com", reply_to: "support@ulaiber.com"

  layout 'mailer'

  def confirmation_email_instructions(email)
    @email = email
    @expire_time = Time.now + 30.minutes
    @confirm_url = new_user_registration_url(
      confirmation_token: CryptService.generate_message([email, @expire_time]),
      regist_type: 'email'
    )
    mail(to: email, subject: 'UBOSS邮件注册确认')
  end

end
