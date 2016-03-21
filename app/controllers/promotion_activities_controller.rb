class PromotionActivitiesController < ApplicationController
  layout 'activity', only: [:show, :live_draw, :share_draw]

  def show
    #if ['live', 'share'].include?(params[:type])
    #  @type = params[:type]
    #  @promotion_activity = PromotionActivity.find(params[:id])
    #else
    #  redirect_to root_path
    #end
  end

  def live_draw
    @promotion_activity = PromotionActivity.find(params[:id])
    @live_activity_info = @promotion_activity.live_activity_info
    @draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.id, promotion_activity_id: @promotion_activity.id, activity_type: 'live')
    unless @draw_prize.present?
      @message ||= {}
      if @live_activity_info.promotion_activity.status == 'published'
        begin
          live_activity_prize = @live_activity_info.draw_live_prize(current_user.id)
          if live_activity_prize.present?
            @message[:success] = "你中奖了！"
            @message[:info] = "恭喜，你中奖了！赶快分享二维码给朋友，获得更多中奖机会吧~"
          else
            @message[:success] = "没有抽中"
            @message[:info] = "非常遗憾，你没有抽中。不过分享你的二维码给他人一样有机会中奖哦！"
          end
        rescue RepeatedActionError
          @message[:success] = "已经抽过奖了"
          @message[:info] = "你已经抽过奖了，分享你的二维码给他人还有机会中奖哦！"
        end
      else
        if @live_activity_info.promotion_activity.status == 'closed'
          @message[:error] = "活动已过期。"
        elsif @live_activity_info.promotion_activity.status == 'unpublish'
          @message[:error] = "活动尚未开始。"
        else
          @message[:error] = "未知错误，请联系管理员。"
        end
        flash[:error] = @message[:error]
        redirect_to lotteries_account_verify_codes_path
        return
      end
    end
  end

  def share_draw
    @promotion_activity = PromotionActivity.find(params[:id])
    @service_store = @promotion_activity.user.service_store
    @share_activity_info = @promotion_activity.share_activity_info
    sharer_id = SharingNode.find_by(code: params[:sharing_node]).try(:user).try(:id)
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
            @message[:success] = "你中奖了！"
            @message[:info] = "恭喜，你中奖了！赶快分享二维码给朋友，获得更多中奖机会吧~"
          else
            @message[:success] = "没有抽中"
            @message[:info] = "非常遗憾，你没有抽中。不过分享你的二维码给他人一样有机会中奖哦！"
          end
        rescue RepeatedActionError
          @message[:success] = "已经抽过奖了"
          @message[:info] = "你已经抽过奖了，分享你的二维码给他人还有机会中奖哦！"
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
  end

end
