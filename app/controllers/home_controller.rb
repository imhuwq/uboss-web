class HomeController < ApplicationController

  layout :detct_device_layout, only: [:index]
  before_action :detect_device_type

  def index
    if !desktop_request?
      redirect_to products_path
    end
  end

end
