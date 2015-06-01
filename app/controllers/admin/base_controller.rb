class Admin::BaseController < BaseController
  def signed_in_user
    unless signed_in?
      redirect_to :controller=>"admin/sessions",:action=>:new unless signed_in?
    end
  end
end
