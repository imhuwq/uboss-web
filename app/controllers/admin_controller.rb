class AdminController < ApplicationController
  layout 'admin'
  def current_user
     User.first
   end
end
