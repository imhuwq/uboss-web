class BankCard < ActiveRecord::Base

  belongs_to :user

  validates :number, :username, :user_id, :bankname, presence: true

end
