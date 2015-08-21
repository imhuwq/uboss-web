class HomeController < ApplicationController

  detect_device only: [:index, :service_centre_consumer, :service_centre_agent, :service_centre_tutorial]

  def index
    #if !desktop_request?
      #redirect_to products_path
    #end
  end

  def service_centre_consumer
  end

  def service_centre_agent
  end

  def service_centre_tutorial
  end

end
