class BankCard < ActiveRecord::Base

  belongs_to :user

  validates :number, :name, :user_id, :bank_name, presence: true

end
