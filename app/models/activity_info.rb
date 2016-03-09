class ActivityInfo < ActiveRecord::Base
  belongs_to :promotion_activity

  validates :activity_type, :name, :price, :expiry_days, :win_count, :win_rate, presence: true
  validates :activity_type, inclusion: { in: %w(live share) }
  validates :win_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :promotion_activity_id, uniqueness: { scope: :activity_type }
end
