class Clerk < ActiveRecord::Base
  belongs_to :user
  validates :name, presence: true
  validates :mobile, uniqueness: true
end
