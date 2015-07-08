class UserAddress < ActiveRecord::Base
  include Orderable

  belongs_to :user

  validates :username, :mobile, :street, presence: true
  validates :mobile, mobile: true

  def to_s
    "#{province} #{city} #{area} #{street} #{building}"
  end

end
