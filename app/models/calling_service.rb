class CallingService < ActiveRecord::Base
  has_many   :calling_notifies
  belongs_to :user

  validates :user_id, :name, presence: true
end
