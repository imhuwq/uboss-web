class Express < ActiveRecord::Base
  has_and_belongs_to_many :users, uniq: true
end
