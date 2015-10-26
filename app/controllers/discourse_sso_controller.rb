class DiscourseSsoController < ApplicationController

  def sso
    if current_user
      secret = ENV['SECRET']
      sso = SingleSignOn.parse(request.query_string, secret)
      sso.email = current_user.email
      sso.external_id = ENV['KEY'] # unique to your application
      sso.sso_secret = secret
      redirect_to sso.to_url(ENV['CALLBACK_URL'])
    else
      cookies[:is_sso_url] = true
      redirect_to(new_user_session_url)
    end
  end

end
