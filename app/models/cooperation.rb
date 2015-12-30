class Cooperation < ActiveRecord::Base
  belongs_to :supplier, class_name: 'User'
  belongs_to :agency, class_name: 'User'
  validates :supplier_id, presence: true
  validates :agency_id, presence: true
end
