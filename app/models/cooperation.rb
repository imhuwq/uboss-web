class Cooperation < ActiveRecord::Base
  belongs_to :supplier, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  validates :supplier_id, presence: true
  validates :seller_id, presence: true
end
