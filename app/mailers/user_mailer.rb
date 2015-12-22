class UserMailer < Devise::Mailer

  default from: "support@ulaiber.com", reply_to: "support@ulaiber.com"
  layout 'mailer'

end
