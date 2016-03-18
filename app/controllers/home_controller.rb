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
    if params[:type] == 'service'
      @promotion_activity = PromotionActivity.find_by(user_id: params[:sid], status: 1)
      @draw_prize = ActivityPrize.find_by(prize_winner_id: current_user.try(:id), promotion_activity_id: @promotion_activity.try(:id), activity_type: 'live')
    end

    if current_user
      privilege_card = PrivilegeCard.find_or_active_card(current_user.id, params[:sid])
      if @promotion_activity.present?
        if @draw_prize.present?
          @live_activity_info = @promotion_activity.live_activity_info
          render 'promotion_activities/live_draw', layout: 'activity'
        else
          redirect_to promotion_activity_path(@promotion_activity, type: 'live')
        end
      else
        @qrcode_img_url = params[:type] == 'ordinary' ? privilege_card.ordinary_store_qrcode_img_url(true) : privilege_card.service_store_qrcode_img_url(true)
        render layout: nil
      end
    else
      if @promotion_activity.present?
        redirect_to activity_sign_in_and_redirect_path('live', @promotion_activity)
      else
        authenticate_user!
      end
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
