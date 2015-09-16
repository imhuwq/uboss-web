class DifferentArea < ActiveRecord::Base
  belongs_to :carriage_template
  has_and_belongs_to_many :regions

  validates :first_item, :carriage, :extend_item, :extend_carriage, presence: true
end
