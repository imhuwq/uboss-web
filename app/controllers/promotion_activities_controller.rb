class PromotionActivitiesController < ApplicationController
  layout 'activity', only: [:show, :live_draw]

  def show
    #@promotion_activity = PromotionActivity.find(params[:id])
  end

  def live_draw
    @promotion_activity = PromotionActivity.find(params[:id])
    @live_activity_info = @promotion_activity.live_activity_info
    @draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.id, promotion_activity_id: @promotion_activity.id, activity_type: 'live')
  end

  def share_draw
    @promotion_activity = PromotionActivity.find(params[:id])
    @share_activity_info = @promotion_activity.share_activity_info
    #@draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.id, promotion_activity_id: @promotion_activity.id, sharer_id: 'sharer_id')
    @draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.id, promotion_activity_id: @promotion_activity.id, activity_type: 'live')
  end

  def draw_prize
    activity_info = ActivityInfo.find(params[:activity_info_id])
    if activity_info.promotion_activity.status == 'published'
      begin
        live_activity_prize = activity_info.draw_live_prize(current_user.id)
        if live_activity_prize.present?
          @message[:success] = "你中奖了！"
          @message[:info] = "恭喜，你中奖了！赶快分享二维码给朋友，获得更多中奖机会吧~"
        else
          @message[:info] = "非常遗憾，你没有抽中。不过分享你的二维码给他人一样有机会中奖哦！"
        end
      rescue RepeatedActionError
        @message[:info] = "你已经抽过奖了，分享你的二维码给他人还有机会中奖哦！"
      end
    elsif activity_info.promotion_activity.status == 'closed'
      @message[:error] = "活动已过期。"
    elsif activity_info.promotion_activity.status == 'unpublish'
      @message[:error] = "活动尚未开始。"
    else
      @message[:error] = "未知错误，请联系管理员。"
    end
    render json: @message.to_ajax
    render json: {success: '你中奖了！', info:  "恭喜，你中奖了！你的分享者--也收到了一份奖品，赶快让他(她)请你吃饭吧:P"}
  end


end
