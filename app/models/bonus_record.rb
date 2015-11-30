class BonusRecord < ActiveRecord::Base

  belongs_to :user

  validates :amount, money: true

end
