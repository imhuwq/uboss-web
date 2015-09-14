class DifferentArea < ActiveRecord::Base
  belongs_to :carriage_template
  belongs_to :state
end
