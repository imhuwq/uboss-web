class AgreementsController < ApplicationController

  layout :agreement_layout

  private

  def agreement_layout
    if desktop_request?
      'login'
    else
      'mobile'
    end
  end

end
