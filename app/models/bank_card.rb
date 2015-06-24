class BankCard < ActiveRecord::Base

  belongs_to :user

  validates :number, :name, :user_id, presence: true

end
