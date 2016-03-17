class PromotionActivitiesController < ApplicationController
  def draw_prize
    # activity_info = ActivityInfo.find(params[:activity_info_id])
    # if activity_info.promotion_activity.status == 'published'
    #   sharer_id = params[:sharer_id]
    #   prize_ids = activity_info.draw_prize(current_user.id, sharer_id)
    #   if prize_ids[:sharer_activity_prize_id]
    #     sharer_name = ActivityPrize.find(prize_ids[:sharer_activity_prize_id]).prize_winner.identity
    #     @message[:success] = "你中奖了！"
    #     @message[:info] = "恭喜，你中奖了！你的分享者-#{sharer_name}-也收到了一份奖品，赶快让他(她)请你吃饭吧:P"
    #   elsif verify_code_id == nil
    #     @message[:info] = "非常遗憾，你没有抽中。不过分享你的二维码给他人一样有机会中奖哦！"
    #   else
    #     @message[:error] = "未知错误，请联系管理员。"
    #   end
    # elsif activity_info.promotion_activity.status == 'closed'
    #   @message[:error] = "活动已过期。"
    # elsif activity_info.promotion_activity.status == 'unpublish'
    #   @message[:error] = "活动尚未开始。"
    # else
    #   @message[:error] = "未知错误，请联系管理员。"
    # end
    # render json: @message.to_ajax
    render json: {success: '你中奖了！', info:  "恭喜，你中奖了！你的分享者--也收到了一份奖品，赶快让他(她)请你吃饭吧:P"}
  end


end
