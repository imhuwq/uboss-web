class PromotionActivitiesController < ApplicationController
  include SharingResource

  before_action :check_current_user, only: [:live_draw, :share_draw]
  before_action :check_param_type,   only: :show
  layout 'activity'

  def show
    @promotion_activity = PromotionActivity.published.find(params[:id])
    @type = params[:type]

    if current_user
      if @type == "share"
        activity_info = @promotion_activity.share_activity_info
        draw_path = share_draw_promotion_activity_path(@promotion_activity)
      else
        activity_info = @promotion_activity.live_activity_info
        draw_path = live_draw_promotion_activity_path(@promotion_activity)
      end

      @draw_record = current_user.activity_draw_records.find_by(activity_info_id: activity_info.id)
      if @draw_record.present? || params[:redirect] == "draw"
        redirect_to draw_path
      end
    else
      if browser.wechat?
        redirect = 'draw'
        authenticate_weixin_user!(redirect)
      else
        redirect_to activity_sign_in_and_redirect_path(@type, @promotion_activity)
      end
    end
  end

  def live_draw
    @promotion_activity = PromotionActivity.published.find(params[:id])
    @message ||= {}
    begin
      live_activity_info = @promotion_activity.live_activity_info
      if live_activity_info.draw_live_prize(current_user.id)
        @message[:success] = "中奖了，恭喜获得“#{live_activity_info.name}” ！"
      else
        @message[:success] = "(*^_^*) 没中，请再接再厉"
      end
    rescue ActivityInfo::RepeatedDrawError
      @message[:success] = "^o^ 亲您已抽过，下次再来吧"
    end

    get_service_store_qrcode_img_url
  end

  def share_draw
    @promotion_activity = PromotionActivity.published.find(params[:id])
    @seller = @promotion_activity.user
    @service_store = @seller.service_store
    get_sharing_node
    sharer_id = @sharing_node.try(:user_id)

    @message ||= {}
    begin
      share_activity_info = @promotion_activity.share_activity_info
      if share_activity_info.draw_share_prize(current_user.id, sharer_id)
        @message[:success] = "中奖了，恭喜获得“#{share_activity_info.name}” ！"
      else
        @message[:success] = "(*^_^*) 没中，请再接再厉"
      end
    rescue ActivityInfo::SharerNotFoundError
      flash[:error] = "找不到对应的分享者，请重新获取分享信息"
      redirect_to lotteries_account_verify_codes_path
      return
    rescue ActivityInfo::RepeatedDrawError
      @message[:success] = "^o^ 亲您已抽过，下次再来吧"
    end

    get_service_store_qrcode_img_url
  end

  protected

  def check_param_type
    if !['live', 'share'].include?(params[:type])
      redirect_to root_path
    end
  end

  def check_current_user
    if current_user.blank?
      redirect_to root_path
    end
  end

  def get_service_store_qrcode_img_url
    privilege_card = PrivilegeCard.find_or_active_card(current_user.id, @promotion_activity.user_id)
    @qrcode_img_url = privilege_card.service_store_qrcode_img_url(true)
  end

  def find_activity_prize_by(type, sharer_id = nil)
    ActivityPrize.find_by(prize_winner_id: current_user.id,
                          promotion_activity_id: @promotion_activity.id,
                          sharer_id: sharer_id,
                          activity_type: type
                         )
  end
end
