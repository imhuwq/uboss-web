class UserAddress < ActiveRecord::Base
  belongs_to :user

  validates :username, :mobile, :street, presence: true

  def to_s
    "#{province} #{city} #{country} #{street}"
  end

end
