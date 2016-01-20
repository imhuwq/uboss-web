module WechatRewarable
  extend ActiveSupport::Concern

  included do
    after_action :grant_weixin_invite_reward, if: -> {
      session[:scene_identify].present? && current_user.present?
    }
  end

  def grant_weixin_invite_reward
    Ubonus::WeixinInviteReward.delay.
      active_with_to_wx_user(current_user.id, session[:scene_identify])
    session[:scene_identify] = nil
  end

end
