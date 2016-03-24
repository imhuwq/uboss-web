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

      @draw_record = current_user.activity_draw_records.find_by(activity_info_id: activity_info.id, sharer_id: sharer_id)
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
    @message ||= {}
    begin
      live_activity_prize = PromotionActivity.published.find(params[:id]).live_activity_info.draw_live_prize(current_user.id)
      if live_activity_prize.present?
        @message[:success] = "您中奖了！"
      else
        @message[:success] = "没有抽中"
      end
    rescue RepeatedActionError
      @message[:success] = "已经抽过奖了"
    rescue ActivityNotPublishError
      flash[:error] = "活动还没开始"
      redirect_to root_path
    end

    get_service_store_qrcode_img_url
  end

  def share_draw
    @promotion_activity = PromotionActivity.find(params[:id])
    @service_store = @promotion_activity.user.service_store
    get_sharing_node
    sharer_id = @sharing_node.try(:user_id)

    @message ||= {}
    begin
      share_activity_prize = @promotion_activity.share_activity_info.draw_share_prize(current_user.id, sharer_id)
      if share_activity_prize.present?
        @message[:success] = "恭喜，您中奖了！"
      else
        @message[:success] = "没有抽中"
      end
    rescue ActivityNotPublishError
      flash[:error] = "活动还没开始"
      redirect_to lotteries_account_verify_codes_path
      return
    rescue SharerNotFoundError
      flash[:error] = "找不到对应的分享者，请重新获取分享信息"
      redirect_to lotteries_account_verify_codes_path
      return
    rescue RepeatedActionError
      @drawed_prize = true
      @message[:success] = "已经抽过奖了"
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
