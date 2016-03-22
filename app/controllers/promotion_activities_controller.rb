class PromotionActivitiesController < ApplicationController
  include SharingResource

  before_action :check_current_user, only: [:live_draw, :share_draw]
  before_action :check_param_type,   only: :show
  layout 'activity', only: [:show, :live_draw, :share_draw]

  def show
    @type = params[:type]
    @promotion_activity = PromotionActivity.find(params[:id])

    if current_user
      if @draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.try(:id), promotion_activity_id: @promotion_activity.try(:id), activity_type: 'live')
        redirect_to @type == 'live' ? live_draw_promotion_activity_path(@promotion_activity) : share_draw_promotion_activity_path(@promotion_activity)
        return
      end

      if params[:redirect] == "draw"
        redirect_to @type == 'live' ? live_draw_promotion_activity_path(@promotion_activity) : share_draw_promotion_activity_path(@promotion_activity)
      end
    else
      if browser.wechat?
        redirect = 'draw'
        authenticate_weixin_user!(redirect)
      else
        redirect_to activity_sign_in_and_redirect_path('live', @promotion_activity)
      end
    end
  end

  def live_draw
    @promotion_activity = PromotionActivity.find(params[:id])
    @live_activity_info = @promotion_activity.live_activity_info
    @draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.id, promotion_activity_id: @promotion_activity.id, activity_type: 'live')
    @message ||= {}

    unless @draw_prize.present?
      if @promotion_activity.status == 'published'
        begin
          live_activity_prize = @live_activity_info.draw_live_prize(current_user.id)
          if live_activity_prize.present?
            @message[:success] = "您中奖了！"
          else
            @message[:success] = "没有抽中"
          end
        rescue RepeatedActionError
          @message[:success] = "已经抽过奖了"
        end
      else
        if @promotion_activity.status == 'closed'
          @message[:error] = "活动已过期。"
        elsif @promotion_activity.status == 'unpublish'
          @message[:error] = "活动尚未开始。"
        else
          @message[:error] = "未知错误，请联系管理员。"
        end
        flash[:error] = @message[:error]
        redirect_to lotteries_account_verify_codes_path
        return
      end
    else
      @message[:success] = "亲，您已经抽过奖了"
    end

    get_service_store_qrcode_img_url
  end

  def share_draw
    @promotion_activity = PromotionActivity.find(params[:id])
    @seller = @promotion_activity.user
    @service_store = @seller.service_store
    @share_activity_info = @promotion_activity.share_activity_info
    get_sharing_node
    sharer_id = @sharing_node.try(:user_id)
    if sharer_id && sharer_id != current_user.id
      @draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.id,
                                          promotion_activity_id: @promotion_activity.id,
                                          sharer_id: sharer_id,
                                          activity_type: 'share')
    else
      flash[:error] = "找不到对应的分享者，请重新获取分享信息"
      redirect_to lotteries_account_verify_codes_path
      return
    end

    if sharer_id && !@draw_prize.present?
      @message ||= {}
      if @share_activity_info.promotion_activity.status == 'published'
        begin
          share_activity_prize = @share_activity_info.draw_share_prize(current_user.id, sharer_id)
          if share_activity_prize.present?
            @message[:success] = "恭喜，您中奖了！"
          else
            @message[:success] = "没有抽中"
          end
        rescue RepeatedActionError
          @message[:success] = "已经抽过奖了"
        end
      else
        if @share_activity_info.promotion_activity.status == 'closed'
          @message[:error] = "活动已过期。"
        elsif @share_activity_info.promotion_activity.status == 'unpublish'
          @message[:error] = "活动尚未开始。"
        else
          @message[:error] = "未知错误，请联系管理员。"
        end
        flash[:error] = @message[:error]
        redirect_to lotteries_account_verify_codes_path
        return
      end
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

end
