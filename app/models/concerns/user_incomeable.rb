module UserIncomeable
  extend ActiveSupport::Concern
  
  included do
    after_create do
      create!(resource: self, amount: amount, user_id: user_id)
    end
  end
end