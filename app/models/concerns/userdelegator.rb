module Userdelegator
  extend ActiveSupport::Concern
  included do
    delegate :login, :identify, :mobile, :avatar, :sales, :turnovers, to: :user, allow_nil: true, prefix: true
  end
end