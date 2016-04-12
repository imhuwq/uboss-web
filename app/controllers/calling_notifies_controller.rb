class CallingNotifiesController < ApplicationController
  before_action :authenticate_user!
  layout 'calling_services'

  def index
    @calling_notifies = current_user.calling_notifies
  end

end
