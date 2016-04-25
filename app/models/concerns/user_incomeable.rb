module UserIncomeable
  extend ActiveSupport::Concern
  
  included do
    after_create do
      UserIncome.create!(resource: self, amount: amount, user_id: user_id)
    end
  end
end