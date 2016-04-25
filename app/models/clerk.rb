class Clerk < ActiveRecord::Base
  belongs_to :user
  validates :name, :mobile, presence: true
  validates :mobile, uniqueness: true
end
