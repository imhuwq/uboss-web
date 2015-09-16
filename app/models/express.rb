class Express < ActiveRecord::Base
  has_and_belongs_to_many :users, uniq: true
  has_many :orders

  validates :name, presence: true, uniqueness: true
end
