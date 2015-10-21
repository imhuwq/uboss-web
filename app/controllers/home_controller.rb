class HomeController < ApplicationController

  detect_device only: [:index, :service_centre_consumer, :service_centre_agent, :service_centre_tutorial]

  layout :detect_layout, only: [:index, :service_centre_tutorial, :service_centre_agent, :service_centre_consumer]

  def index
    if !desktop_request?
      @products = append_default_filter Product.published.includes(:asset_img), order_column: :updated_at
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
    render 'accounts/maker_qrcode', layout: false
  end

  def about_us
    render layout: 'mobile'
  end

  def qrcode
    url = QrcodeService.request_qrcode_url(params.fetch(:text), params[:logo])
    if url.present?
      redirect_to url
    else
      head(422)
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
