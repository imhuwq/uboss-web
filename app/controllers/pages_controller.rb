class PagesController < ApplicationController

  def bonus_invite
    session[Ubonus::Invite::RAND_BONUS_SESSIONS_KEY] ||= Ubonus::Invite.rand_benefit_for_inviting
    render layout: nil
  end

end
