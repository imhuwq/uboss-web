module DetectDevise
  extend ActiveSupport::Concern

  module ClassMethods
    def detect_device options={}
      # layout :detect_device_layout, options
      before_action :detect_device_type, options
    end
  end

  private

  def desktop_request?
    !browser.mobile? && !browser.tablet? && params[:luffy_mobile].blank?
  end

  def detect_device_layout
    if desktop_request?
      'desktop'
    end
  end

  def detect_device_type
    if desktop_request?
      prepend_view_path Rails.root + 'app/views' + 'desktop'
    end
  end

end
