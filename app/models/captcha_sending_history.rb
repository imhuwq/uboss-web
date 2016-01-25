class CaptchaSendingHistory < ActiveRecord::Base
  enum invite_type: [:invite_seller, :invite_agency]
  enum invite_status: [:already_sent, :failed, :success]
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
end
