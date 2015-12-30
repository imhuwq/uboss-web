ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_url_options = {
  host: Rails.application.secrets.mail['url_host']
}
ActionMailer::Base.smtp_settings = {
  address:        Rails.application.secrets.mail['address'],
  port:           Rails.application.secrets.mail['port'],
  authentication: Rails.application.secrets.mail['authentication'],
  user_name:      Rails.application.secrets.mail['user_name'],
  password:       Rails.application.secrets.mail['password'],
  domain:         Rails.application.secrets.mail['domain']
}
