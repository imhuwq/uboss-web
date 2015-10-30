class DiscourseSsoController < ApplicationController

  def sso
    if current_user.present?
      sso = SingleSignOnService.parse(request.query_string)
      sso.assign_attributes_with_user(current_user)

      Rails.logger.debug("Redirect To Discourse With Playload: #{sso.unsigned_payload}")
      redirect_to sso.to_url
    else
      redirect_to(new_user_session_url(redirect: 'discourse', redirectUrl: request.fullpath))
    end
  end

end
