class DifferentArea < ActiveRecord::Base
  belongs_to :carriage_template
  belongs_to :state

  delegate :name, to: :state

  validates :first_item, :carriage, :extend_item, :extend_carriage, presence: true
end
