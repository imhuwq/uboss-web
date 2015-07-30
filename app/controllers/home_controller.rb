class HomeController < ApplicationController
  layout 'desktop'
  detect_device only: [:index,:help]

  def index
    if !desktop_request?
      redirect_to products_path
    end
  end

  def help
  end
end
