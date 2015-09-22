class Category < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :products

  validates_presence_of :user_id, :name
end
