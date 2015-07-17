class HomeController < ApplicationController

  detect_device only: [:index]

  def index
    if !desktop_request?
      redirect_to products_path
    end
  end

end
