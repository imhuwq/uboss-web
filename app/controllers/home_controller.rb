class HomeController < ApplicationController

  detect_device only: [:index, :service_centre_consumer, :service_centre_agent, :service_centre_tutorial]

  layout :detect_layout, only: [:index, :service_centre_tutorial, :service_centre_agent, :service_centre_consumer, :lady, :maca, :snacks,:city]

  def index
    if !desktop_request?
      redirect_to stores_path
    end
  end

  def service_centre_consumer
  end

  def service_centre_agent
  end

  def service_centre_tutorial
  end

  def maker_qrcode
    @user = User.find(params.fetch(:uid))
    render layout: false
  end

  def about_us
    render layout: 'mobile'
  end

  def qrcode
    qrcode = QrcodeService.new(params.fetch(:text), params[:logo])
    if qrcode.url.present?
      redirect_to qrcode.url
    else
      head(422)
    end
  end

  def hongbao_game
    render layout: nil
  end

  def store_qrcode_img
    if current_user
      if ['ordinary', 'service'].include?(params[:type]) && (privilege_card = PrivilegeCard.find_or_active_card(current_user.id, params[:sid]))
        @qrcode_img_url = params[:type] == 'ordinary' ? privilege_card.ordinary_store_qrcode_img_url(true) : privilege_card.service_store_qrcode_img_url(true)
        seller = User.find(privilege_card.seller_id)
        @promotion_activity = PromotionActivity.where(user_id: seller.id, status: 1).first
        @draw_prize = @promotion_activity ? ActivityPrize.where(promotion_activity_id: @promotion_activity.id, activity_type: 'live').first : nil
      end

      if true
        render 'activity', layout: 'activity'
      else
        render layout: nil
      end
    else
      redirect_to new_user_session_path(redirect: 'activity', redirectUrl: request.env["REQUEST_URI"])
    end
  end

  def draw_prize
    activity_info = ActivityInfo.find(params[:activity_info_id])
    if activity_info.promotion_activity.status == 'published'
      sharer_id = params[:sharer_id]
      prize_ids = activity_info.draw_prize(current_user.id, sharer_id)
      if prize_ids[:sharer_activity_prize_id]
        sharer_name = ActivityPrize.find(prize_ids[:sharer_activity_prize_id]).prize_winner.identity
        @message[:success] = "恭喜，你中奖了！你的分享者-#{sharer_name}-也收到了一份奖品，赶快让他(她)请你吃饭吧:P"
      elsif verify_code_id == nil
        @message[:success] = "非常遗憾，你没有抽中。不过分享你的二维码给他人一样有机会中奖哦！"
      else
        @message[:error] = "未知错误，请联系管理员。"
      end
    elsif activity_info.promotion_activity.status == 'closed'
      @message[:error] = "活动已过期。"
    elsif activity_info.promotion_activity.status == 'unpublish'
      @message[:error] = "活动尚未开始。"
    else
      @message[:error] = "未知错误，请联系管理员。"
    end
  end

  private

  def detect_layout
    if not desktop_request?
      'mobile'
    else
      'desktop'
    end
  end

end
