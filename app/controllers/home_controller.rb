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
    #if current_user
    if true
      #if ['ordinary', 'service'].include?(params[:type]) && (privilege_card = PrivilegeCard.find_or_active_card(current_user.id, params[:sid]))
      #  @qrcode_img_url = params[:type] == 'ordinary' ? privilege_card.ordinary_store_qrcode_img_url(true) : privilege_card.service_store_qrcode_img_url(true)
      #end

      if true
        render 'activity', layout: 'activity'
      else
        render layout: nil
      end
    else
      render 'users/sessions/new_of_activity', layout: 'activity'
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
