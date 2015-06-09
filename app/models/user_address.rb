class UserAddress < ActiveRecord::Base
  belongs_to :user

  validates :username, :mobile, :street, presence: true

end
