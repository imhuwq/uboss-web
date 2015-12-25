module Userdelegator
  extend ActiveSupport::Concern
  included do
    delegate :identify, :mobile, :avatar, :sales, :turnovers, to: :user, allow_nil: true, prefix: true
  end
end